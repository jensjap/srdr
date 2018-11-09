require 'rubyXL'
require 'roo'
require 'fileutils'
require 'cgi'

class ImportHandler  #{{{1

    attr_reader :project_id, :data, :listOf_errors, :listOf_errors_processing_rows

    def initialize(u_id, p_id, ef_id, section, force=false)  #{{{2
        @listOf_errors                      = Array.new
        @listOf_errors_processing_rows      = Array.new
        @listOf_errors_processing_questions = Array.new
        @listOf_email_recipients            = Array.new
        @user_id                            = u_id
        @project_id                         = p_id
        @ef_id                              = ef_id
        @section                            = section
        @local_file_path                    = nil
        @wb                                 = nil
        @headers                            = nil
        @data                               = nil
        @skipped_rows                       = 0
        @force_create_studies               = force

        # Dictionary keys we will use to find values
        @kq_key            = nil
        @pmid_key          = nil
        @internal_id_key   = nil
        @author_key        = nil
        @author_year_key   = nil
        @study_title_key   = nil
        @arm_key           = nil

        # Helps determine how to identify studies
        @study_identifier_type = nil
    end

    # Run several checks to make sure the workbook that was submitted
    # includes the required information needed for importing.
    def validate_workbook  #{{{2
        # Check if a workbook was submitted at all.
        @listOf_errors << "No workbook created. #set_workbook to set a file path" unless @wb

        # Check if the data in the workbook was parsed.
        # Parsing the data returns a list of hashes, one hash per row,
        # where the header is the key and the value cell content.
        @listOf_errors << "No data parsed. #parse_data to parse a workbook with opt'l header row" unless @data
        return false unless @listOf_errors.length==0

        # Having an empty column in the middle of the workbook will
        # cause problems down the road. We check that no such column
        # exists and record an error if it does.
        _verify_no_blank_column
        return false unless @listOf_errors.length==0

        # Key Question column must exist. If it does not we record an error.
        # jj 2014-09-02: This behavior is overwritten later. If kq column does
        #                not exist we default to _all_ kq's associated with ef.
        _verify_kq_in_row(@headers)

        # Find best study identifier in the following order:
        # PMID > Internal ID > Author+Title
        study_identifier_type = _find_study_identifier
        if study_identifier_type.blank?
            @listOf_errors << "Insufficient study identifier values found (PMID > Internal ID > Author+Title) in headers. Workbook is not valid."
        else
            @study_identifier_type = study_identifier_type
        end

        return true ? @listOf_errors.length==0 : false
    end

    # We need to ensure that by_arm, by_outcome, by_diagnostic_test are all
    # set to zero, so that the questions show up only once in their respective
    # sections.
    def set_ef_section_options(ef_id)  #{{{2
        ar_ef = ExtractionForm.find(ef_id)

        # jj 07-02-2014: Request by Bryant. Force Extraction Forms to be finalized.
        ar_ef.is_ready = 1
        ar_ef.save

        # We want to set the by_section flag only when we are importing that
        # particular section.
        case @section
        when :DiagnosticTestDetail
            if ar_ef.is_diagnostic?
                ef_section_option_by_diagnostic_test = EfSectionOption.\
                    where(["extraction_form_id=? AND section=?",
                           ef_id, "diagnostic_test_detail"]).first
                if ef_section_option_by_diagnostic_test
                    ef_section_option_by_diagnostic_test.by_diagnostic_test = 0
                    ef_section_option_by_diagnostic_test.save
                end
            end

#        ### THIS SHOULD NOT BE REQUIRED
#        when :ArmDetail
#            ef_section_option_by_arm = EfSectionOption.\
#                where(["extraction_form_id=? AND section=?",
#                       ef_id, "arm_detail"]).first
#            if ef_section_option_by_arm
#                ef_section_option_by_arm.by_arm = 0
#                ef_section_option_by_arm.save
#            end

        when :OutcomeDetail
            ef_section_option_by_outcome = EfSectionOption.\
                where(["extraction_form_id=? AND section=?",
                       ef_id, "outcome_detail"]).first
            if ef_section_option_by_outcome
              ef_section_option_by_outcome.by_outcome = 0
              ef_section_option_by_outcome.save
            end
        end
    end

    def process_rows  #{{{2
        # Since we do not support by_section imports just yet, we enforce the setting here on the extraction form.
        if [:ArmDetail, :OutcomeDetail, :DiagnosticTestDetail].include? @section
            self.set_ef_section_options(@ef_id)
        end

        @data.each_with_index do |row, ind|
            if _validate_row(row)
                puts "All's well. We can insert row #{ind + 2}."
                process_result = _process_row(row)
                unless process_result
                    @listOf_errors_processing_rows << "Something went wrong while processing row #{ind + 2}."
                end
            else
                puts "Problem encountered. Skipped row #{ind + 2}."
                @listOf_errors_processing_rows << "Something was wrong with row #{ind + 2}. Skipped it."
                @skipped_rows += 1
                next
            end
        end

        # Notify user that processing is complete and if any errors occurred while processing rows.
        Notifier.simple_import_complete(@listOf_email_recipients, @skipped_rows,
                                       @listOf_errors_processing_rows,
                                       @listOf_errors_processing_questions).deliver

        # Delete local file
        begin
            FileUtils.rm @local_file_path
        rescue Errno::ENOENT=>e
            puts "File already gone."
        end
    end

    def add_email_recipient(email)  #{{{2
        @listOf_email_recipients << email
    end

    private  #{{{2

        def _process_row(row)  #{{{3
            ef_id, section, pmid, internal_id, author, study_title,
                year, kq_hash, q_hash, valid_row = _extract_data_from_row(@headers, row)

            if valid_row
                insert_result = _insert_row_into_db(ef_id, section, pmid, internal_id,
                                                    author, study_title, year, kq_hash, q_hash)
                return insert_result
            else
                @listOf_errors_processing_rows << "Problem with values in row '#{row}'. Extracting data from row failed."
                return false
            end
        end

        def _insert_row_into_db(ef_id, section, pmid, internal_id,  #{{{3
                                author, study_title, year, kq_hash, q_hash)

            study_id = _find_study_id(ef_id, section, pmid, internal_id,
                                      author, study_title, year, kq_hash, q_hash)

            # Now that we have the study id we can proceed
            # to insert/update the question hash.
            if study_id
                # We need to ensure that the study to extraction form and
                # the study to key question tables are up to date
                _update_study_extraction_forms_table(ef_id, study_id)
                _update_study_key_questions_tables(ef_id, study_id, kq_hash)

                # There are several optional publication fields that the user may
                # include as study identifiers:
                # affiliation, journal, year, volume, issue, abstract.
                # We process them separately if they exist.
                # This feels a bit fudgy. To be more consistent with our design
                # patterns we should be handling this like a separate section =(
                #unless @study_identifier_type == :pmid
                    q_hash = _process_optional_publication_info(study_id, q_hash)
                #end

                # internal_id, author, study_title,year
                _overwrite_publication_info_with_given_values(study_id, internal_id, author, study_title, year)

                # Now process the question hash
                _process_q_hash(section, q_hash, ef_id, study_id)
                return true
            else
                @listOf_errors_processing_rows << "Failed to determine study_id for PMID '#{pmid}', internal ID '#{internal_id}', author '#{author}', year '#{year}', study title '#{study_title}'"
                return false
            end
        end

        def _overwrite_publication_info_with_given_values(study_id, internal_id, author, study_title, year)  #{{{3
            ar_pp = PrimaryPublication.find_all_by_study_id(study_id).first
            ar_pp.author = author unless author.blank?
            ar_pp.title = study_title unless study_title.blank?
            ar_pp.year = year unless year.blank?
            ar_pp.save

            unless internal_id.blank?
                ar_ppnumbers = PrimaryPublicationNumber.where(["primary_publication_id=? AND number_type=?",
                                                               ar_pp.id, 'internal' ])
                if ar_ppnumbers.length == 0
                    PrimaryPublicationNumber.create(primary_publication_id: ar_pp.id,
                                                    number:                 internal_id,
                                                    number_type:            'internal')
                else
                    ar_ppnumber = ar_ppnumbers.first
                    ar_ppnumber.number = internal_id
                    ar_ppnumber.save
                end
            end
        end

        def _process_optional_publication_info(study_id, q_hash)  #{{{3
            q_hash.each do |q, a|
                #case q
                #when /^affiliations?$|^journals?$|^volumes?$|^issues?$|^abstracts?$/i
                if /^['"]*affiliation[s'"\s]*$|^['"]*journal[s'"\s]*$|^['"]*volume[s'"\s]*$|^['"]*issue[s'"\s]*$|^['"]*abstract[s'"\s]*$/i.match(q)
                    unless a.blank?
                        _optional_publication_info(study_id, q, a)
                    end
                    q_hash.except!(q)
                end
            end

            return q_hash
        end

        def _optional_publication_info(study_id, q, a)  #{{{3
            ar_pp = PrimaryPublication.find_all_by_study_id(study_id).first

            if q.is_a? String
                q_value = CGI.unescapeHTML(q).downcase
            else
                q_value = q
            end

            if a.is_a? String
                a_value = CGI.unescapeHTML(a)
            else
                a_value = a
            end

            # Affiliations is actually saved under 'country' column.
            q_value = q_value.sub(/^affiliations?$/i, 'country')
            #q.sub!(/^affiliations?$/, 'country')

            ar_pp[q_value] = a
            #ar_pp[q] = a
            ar_pp.save
        end

        def _find_study_id(ef_id, section, pmid, internal_id,  #{{{3
                           author, study_title, year, kq_hash, q_hash)
            case @study_identifier_type
            when :pmid
                study_id = _find_study_id_by_pmid(@project_id, ef_id, pmid, kq_hash)
            when :internal_id
                study_id = _find_study_id_by_internal_id(@project_id, ef_id, internal_id, author, study_title, year, kq_hash)
            when :author_title
                study_id = _find_study_id_by_author_title(@project_id, ef_id, internal_id, author, study_title, year, kq_hash)
            end

            return study_id
        end

        def _find_study_id_by_author_title(project_id, ef_id, internal_id, author, study_title, year, kq_hash)  #{{{3
            ar_studies = Study.joins(:primary_publication).\
                               where(["studies.project_id=? AND primary_publications.author like ? AND primary_publications.title like ?",
                                      project_id, "%"+author+"%", "%"+study_title+"%"])
            if ar_studies.length > 1
                @listOf_errors_processing_rows << "More than 1 study find with author '#{author}' and study title '#{study_title}'."
                @skipped_rows += 1
                return false
            elsif ar_studies.length == 1
                return ar_studies.first.id
            else
                study_id = _create_study_record_without_pmid(project_id, ef_id, kq_hash,
                                                            author, year, study_title, internal_id)
                return study_id
            end
        end

        def _find_study_id_by_internal_id(project_id, ef_id, internal_id, author, study_title, year, kq_hash)  #{{{3
            ar_studies = Study.joins(:primary_publication).\
                               joins(:primary_publication_numbers).\
                               where(["studies.project_id=? AND primary_publication_numbers.number_type=? AND primary_publication_numbers.number=?",
                                      project_id, 'internal', internal_id])
            if ar_studies.length > 1
                @listOf_errors_processing_rows << "More than 1 study find with internal id '#{internal_id}'."
                @skipped_rows += 1
                return false
            elsif ar_studies.length == 1
                return ar_studies.first.id
            else
                study_id = _create_study_record_without_pmid(project_id, ef_id, kq_hash,
                                                            author, year, study_title, internal_id)
                return study_id
            end
        end

        def _find_study_id_by_pmid(project_id, ef_id, pmid, kq_hash)  #{{{3
            ar_studies = Study.joins(:primary_publication).\
                where(["studies.project_id=? AND primary_publications.pmid=?",
                       project_id, pmid])

            if ar_studies.length == 0
                study_id = _create_study_record_using_pmid(pmid, kq_hash, ef_id)
                return study_id
            elsif ar_studies.length > 1
                ar_studies = Study.joins(:primary_publication).\
                                   joins(:study_extraction_forms).\
                    where(["studies.project_id=? AND study_extraction_forms.extraction_form_id=? AND primary_publications.pmid=?",
                           project_id, ef_id, pmid])
                if ar_studies.length == 0
                    # Nira requests that we create a new study if we are updating, i.e.
                    # force study creation is set to false, but encounter a study that does not
                    # yet exist.
                    study_id = _create_study_record_using_pmid(pmid, kq_hash, ef_id)
                    return study_id
                else
                    # Pull/resave publication information again in case something's changed.
                    summary = SecondaryPublication.get_summary_info_by_pmid(pmid)
                    ar_pp = PrimaryPublication.find_all_by_study_id(ar_studies.first.id).last
                    ar_pp.title = summary[0]
                    ar_pp.author = summary[1]
                    ar_pp.country = summary[2]
                    ar_pp.year = summary[3]
                    ar_pp.journal = summary[4]
                    ar_pp.volume = summary[5]
                    ar_pp.issue = summary[6]
                    ar_pp.abstract = summary[7]
                    ar_pp.save

                    # If there are two studies with the same PMID answering the same extraction form,
                    # this will only return the last
                    return ar_studies.last.id
                end
            else
                # Pull/resave publication information again in case something's changed.
                summary = SecondaryPublication.get_summary_info_by_pmid(pmid)
                ar_pp = PrimaryPublication.find_all_by_study_id(ar_studies.first.id).first
                ar_pp.title = summary[0]
                ar_pp.author = summary[1]
                ar_pp.country = summary[2]
                ar_pp.year = summary[3]
                ar_pp.journal = summary[4]
                ar_pp.volume = summary[5]
                ar_pp.issue = summary[6]
                ar_pp.abstract = summary[7]
                ar_pp.save
                return ar_studies.first.id
            end

        end

        def _process_q_hash(section, q_hash, ef_id, study_id)  #{{{3
            case section
            when :AdverseEvent
                _process_q_hash_adverse_event(section, q_hash, ef_id, study_id)
            when :QualityDimension
                #!!! Not ready yet
            when :QualityRating
                #!!! Not ready yet
            when :Arm
                _process_q_hash_arm(section, q_hash, ef_id, study_id)
            when :Outcome
                _process_q_hash_outcome(section, q_hash, ef_id, study_id)
            else # Defaults for :DesignDetail, :ArmDetail, :BaselineCharacteristic, :OutcomeDetail
                _process_q_hash_default(section, q_hash, ef_id, study_id)
            end
        end

        def _process_q_hash_adverse_event(section, q_hash, ef_id, study_id)
            # Test if question hash includes 'Harm' or 'Adverse Events'
            # If it does then we use run method that allows for multiple
            # Adverse Events per study; else use the one that only allows
            # one.
            ae_title_key           = q_hash.keys.find { |k| k =~ /^harms?$|^adverse\s?events?$/i }
            ae_description_key     = q_hash.keys.find { |k| k =~ /^harms?\s?descriptions?$|^adverse\s?events?\s?descriptions?$/i }
            ae_arm_key             = q_hash.keys.find { |l| l =~ /^arms?$/i }
            ae_arm_description_key = q_hash.keys.find { |l| l =~ /^arms?\s?descriptions?$/i }

            # Set defaults
            ae_title           = nil
            ae_description     = nil
            ae_arm             = nil
            ae_arm_description = nil

            # If keys were found in the header then assign values
            ae_title           = q_hash[ae_title_key]           if ae_title_key
            ae_description     = q_hash[ae_description_key]     if ae_description_key
            ae_arm             = q_hash[ae_arm_key]             if ae_arm_key
            ae_arm_description = q_hash[ae_arm_description_key] if ae_arm_description_key

            # If keys were found in the header then remove key from q_hash
            q_hash.except!(ae_title_key)           if ae_title_key
            q_hash.except!(ae_description_key)     if ae_description_key
            q_hash.except!(ae_arm_key)             if ae_arm_key
            q_hash.except!(ae_arm_description_key) if ae_arm_description_key

            # Iterate over the remaining question answer columns
            q_hash.each do |q, a|
                ae_import_handler = ImportAdverseEventHandler.new(section, ef_id, study_id, q, a)
                errors = ae_import_handler.run(ae_title, ae_description, ae_arm, ae_arm_description)
                @listOf_errors_processing_questions.concat errors unless errors.blank?
            end
        end

        def _process_q_hash_arm(section, q_hash, ef_id, study_id)
            arm_import_handler = ImportArmHandler.new(section, ef_id, study_id, q_hash)
            errors = arm_import_handler.run
            @listOf_errors_processing_questions.concat errors unless errors.blank?
        end

        def _process_q_hash_outcome(section, q_hash, ef_id, study_id)
            outcome_import_handler = ImportOutcomeHandler.new(section, ef_id, study_id, q_hash)
            errors = outcome_import_handler.run
            @listOf_errors_processing_questions.concat errors unless errors.blank?
        end

        def _process_q_hash_default(section, q_hash, ef_id, study_id)
            ad_arm_key             = q_hash.keys.find { |l| l =~ /^Arm?$/i }
            ad_arm_description_key = q_hash.keys.find { |l| l =~ /^Arm?\s?Description?$/i }

            ad_arm             = nil
            ad_arm_description = nil

            ad_arm             = q_hash[ad_arm_key]             if ad_arm_key
            ad_arm_description = q_hash[ad_arm_description_key] if ad_arm_description_key

            q_hash.each do |q, a|
                default_import_handler = ImportSectionDetailHandler.new(section, ef_id, study_id, ad_arm, ad_arm_description, q, a)
                errors = default_import_handler.run()
                @listOf_errors_processing_questions.concat errors unless errors.blank?
            end
        end

        def _create_study_record_using_pmid(pmid, kq_hash, ef_id)  #{{{3
            id_list = [pmid]
            study_id, problem_entries = _create_for_pmids(id_list, kq_hash, @project_id, ef_id, @user_id)
            unless problem_entries.length == 0
                @listOf_errors_processing_rows << "Unable to import PMID: #{problem_entries}"
            end

            study_id
        end

        # Ensures that an entry exists associating the study to the extraction form
        def _update_study_extraction_forms_table(ef_id, study_id)  #{{{3
            sefs = StudyExtractionForm.where(["study_id=? AND extraction_form_id=?",
                                             study_id, ef_id])
            if sefs.length == 0
                StudyExtractionForm.create(study_id: study_id, extraction_form_id: ef_id)
            end
        end

        # Ensures that an entry exists associating study to each key question
        def _update_study_key_questions_tables(ef_id, study_id, kq_hash)  #{{{3
            lof_kq_ids = kq_hash.values
            lof_kq_ids.each do |kq_id|
                skqs = StudyKeyQuestion.where(["study_id=? AND key_question_id=? AND extraction_form_id=?",
                                               study_id, kq_id, ef_id])
                if skqs.length == 0
                    StudyKeyQuestion.create(study_id: study_id, key_question_id: kq_id, extraction_form_id: ef_id)
                end
            end
        end

        def _find_list_of_key_question_ids_by_ef_id(ef_id)  #{{{3
            lof_kq_ids = Array.new
            efkqs = ExtractionFormKeyQuestion.where(["extraction_form_id=?", ef_id])
            efkqs.each do |efkq|
                lof_kq_ids << efkq.key_question_id
            end
            return lof_kq_ids
        end

        def _create_study_record_without_pmid(project_id, ef_id, kq_hash,  #{{{3
                                              author="", year="", study_title="", internal_id="")

            ar_study = Study.create(project_id: project_id,
                                    creator_id: @user_id)

            pp = PrimaryPublication.create(study_id: ar_study.id,
                                           title:    study_title,
                                           author:   author,
                                           country:  "",
                                           year:     year,
                                           pmid:     "",
                                           journal:  "",
                                           volume:   "",
                                           issue:    "")

            unless internal_id.blank?
                PrimaryPublicationNumber.create(primary_publication_id: pp.id,
                                                number:                 internal_id,
                                                number_type:            'internal')
            end

            ar_study.assign_kqs_and_efs(kq_hash)

            return ar_study.id
        end

        # Slightly modified from Study.create_for_pmids.
        # For this routine we will only ever pass 1 pmid and so we may ask
        # for the study_id in return
        # @return [Integer] study_id, [Array] pmids_not_found
        def _create_for_pmids(pmids, key_questions, project_id, extraction_form_id, user_id)  #{{{3
            items_not_found = []
            study_id = nil

            pmids.each do |pmid|
                # create a new study and corresponding primary publication
                study = Study.new(:project_id=>project_id, :creator_id=>user_id)

                # if the above information can be saved successfully...
                if study.save
                    # returns an array as [title, authors, year, affiliation]
                    summary = SecondaryPublication.get_summary_info_by_pmid(pmid)
                    puts "SUMMARY @ 0 = #{summary[0]}\n\n"
                    unless summary[0].start_with?("Not Found", "ERROR") 
                        pub = PrimaryPublication.new(:study_id=>study.id,
                                                     :title=>summary[0],
                                                     :author=>summary[1],
                                                     :country=>summary[2],
                                                     :year=>summary[3],
                                                     :pmid=>pmid,
                                                     :journal=>summary[4],
                                                     :volume=>summary[5],
                                                     :issue=>summary[6],
                                                     :abstract=>summary[7] )
                        # if the primary publication can't be saved then it wouldn't have a title, so destroy
                        # the study and keep record of that id

                        if !pub.save
                            study.destroy
                            items_not_found << pmid
                        else
                            study_id = study.id
                            unless key_questions.blank?
                                study.assign_kqs_and_efs(key_questions)
                            end
                            #study.set_defaults
                            #StudyExtractionForm.create(:study_id=>study.id, :extraction_form_id=>extraction_form_id)
                        end

                    # if the pubmed info wasn't found then delete the new study we made
                    # and keep a record of which ids weren't usable 
                    else
                        study.destroy
                        items_not_found << pmid
                    end
                else
                    items_not_found << pmid
                end
            end

            return study_id, items_not_found
        end

        # Uses regexp to find the values for the following keys:
        # pmid, author_year, author, year, kq_hash, q_hash.
        # The kq_hash has the format of { "kq_id" => kq_id }
        # @params [Hash]
        # @params [Array of Hash]
        # @return ef_id, section, pmid, author_year,
        #         author, year, kq_hash, q_hash, valid_row?
        def _extract_data_from_row(headers, row)  #{{{3
            ef_id         = nil
            section       = nil
            pmid          = nil
            author_year   = nil
            author        = nil
            study_title   = nil
            year          = nil
            internal_id   = nil

            # Key Question Hash; format is required by Chris's routine
            # to fetch information from PubMed
            kq_hash     = Hash.new
            q_hash      = Hash.new  # Questions Hash

            headers.keys.each do |k|
                case k
                # This is no longer necessary. Section is provided by the user when
                # submitting the form.
                when /^section$/i
                    section = row[k]
                    #puts "Found Section: #{section}"
                #when /^pubmed[-_\s]*$|^pmid$/i
                when @pmid_key
                    pmid = row[k].to_i
                    #puts "Found PMID: #{pmid}"
                #when /^internal[-_\s]*id$/i
                when @internal_id_key
                    internal_id = row[k]
                    #puts "Found internal id: #{internal_id}"
                #when /^author[-_\s,]*year$/i
                when @author_year_key
                    author_year = row[k]
                    #puts "Found author and year: #{author_year}"
                #when /^authors?$/i
                when @author_key
                    author = row[k]
                    #puts "Found author: #{author}"
                #when /^study[-_\s]*title$|^title$/i
                when @study_title_key
                    study_title = row[k]
                    #puts "Found study title: #{study_title}"
                when /^year$/i
                    year = row[k]
                    #puts "Found year: #{year}"
                #when /^k[ey]*[-_\s]*q[uestion]*$/i
                when @kq_key
                    # This is the form Chris' import program expects the key question hash
                    # jj 06-26-2014: We need to get the kq's this study addresses from the,
                    # spreadsheet after all.
                    if row[k].is_a? String
                        kq_value = CGI.unescapeHTML(row[k])
                    else
                        kq_value = row[k]
                    end
                    kq_hash = _make_kq_hash(kq_value) unless kq_value.blank?
                    #unless kq_hash
                    #    return ef_id, section, pmid, author_year,
                    #           author, year, kq_hash, q_hash, false
                    #end
                else
                    # q_hash = {"My question here"=>"The answer here",
                    #           "Another question"=> "Another answer"}
                    # rubyXL html escapes strings by default. We need to undo this here.
                    if k.is_a? String
                        q_key = CGI.unescapeHTML(k)
                    else
                        q_key = k
                    end
                    if row[k].is_a? String
                        q_value = CGI.unescapeHTML(row[k])
                    else
                        q_value = row[k]
                    end
                    q_hash[q_key] = q_value
                end
            end

            # jj 2014-06-24: section is now supplied by user when upload of
            #                excel file is started
            section = @section
            ef_id   = @ef_id

            # jj 2014-08-27: kq column is now optional. If by now we don't have a kq_hash
            #                we have to make one using all kq's associated with the ef_id.
            if kq_hash.blank?
                kq_hash = _make_kq_hash_from_ef_id(ef_id)
            end

            # Shouldn't have author_year field. We separate them
            author, year = _separate_author_year_if_needed(author, year, author_year)

            return ef_id, section, pmid, internal_id,
                   author, study_title, year, kq_hash, q_hash, true
        end

        def _separate_author_year_if_needed(author, year, author_year)  #{{{3
            if !(author.blank? || year.blank?)
                return author, year
            elsif author.blank? && year.blank?
                unless author_year.blank?
                    _author, _year = author_year.split(/[,\s]+/)
                    return _author, _year
                end
            elsif author.blank?
                unless author_year.blank?
                    _author, _year = author_year.split(/[,\s]+/)
                    return _author, year
                end
                return nil, year
            elsif year.blank?
                unless author_year.blank?
                    _author, _year = author_year.split(/[,\s]+/)
                    return author, _year
                end
                return author, nil
            end

            return nil, nil
        end

        def _make_kq_hash_from_ef_id(ef_id)  #{{{3
            kq_hash = Hash.new

            ar_kqs = KeyQuestion.joins(:extraction_form_key_questions).\
                             where(["extraction_form_key_questions.extraction_form_id=?", ef_id]).\
                             order('key_questions.question_number ASC')
            ar_kqs.each do |kq|
                kq_hash[kq.question_number.to_s] = kq.id
            end

            return kq_hash
        end

        def _make_kq_hash(kq_value)  #{{{3
            lof_kq_question_numbers = Array.new
            kq_hash = Hash.new

            if kq_value.is_a? String
                lof_kq_question_numbers = kq_value.split(/[,\s]+/)
            else
                lof_kq_question_numbers = [kq_value.to_s]
            end

            lof_kq_question_numbers.each do |question_number|
                kq_id = _find_kq_id_from_kq_question_number(question_number)
                if kq_id
                    kq_hash[question_number] = kq_id
                end
            end

            if kq_hash.blank?
                return false
            else
                return kq_hash
            end
        end

        def _find_kq_id_from_kq_question_number(question_number)  #{{{3
            ar_kq = KeyQuestion.where(["project_id=? AND question_number=?",
                                       @project_id, question_number.to_i])
            if ar_kq.length > 1
                @listOf_errors_processing_rows << "Too many key questions found in the database for question number '#{question_number}'"
            elsif ar_kq.length == 0
                @listOf_errors_processing_rows << "No key question matched for question number '#{question_number}'"
            else
                return ar_kq.first.id
            end

            return false
        end

        def _validate_row(row)  #{{{3
            #kq_question_number = row[@kq_key]
            pmid               = row[@pmid_key]
            internal_id        = row[@internal_id_key]
            author             = row[@author_key]
            study_title        = row[@study_title_key]

            ## Make sure key question value (which should be the question number)
            ## matches with a key question in the project which is linked to
            ## an extraction form.
            #ef_id = _find_ef_id_by_kq_question_number(kq_question_number)
            #unless ef_id == @ef_id
            #    @listOf_errors_processing_rows << "Could not match kq number with a correctly associated extraction form."
            #    return false
            #end

            # jj 2014-07-22: We need to set the @study_identifier_type
            #                based on what information is available at the row
            #                level. Each row may have a different set of
            #                identifier values but and it may or may not
            #                be enough information.
            if pmid.blank?
                if internal_id.blank?
                    if author.blank? && study_title.blank?
                        @listOf_errors_processing_rows << "Insufficient study identifiers found (PMID > Internal ID > Author+Title) in row. Row '#{row}' is not valid."
                        return false
                    else
                        @study_identifier_type = :author_title
                    end
                else
                    @study_identifier_type = :internal_id
                end
            else
                @study_identifier_type = :pmid
            end

            return true
        end

        def _find_ef_id_by_kq_question_number(kq_question_number)  #{{{3
            kq_id = _find_kq_id_from_kq_question_number(kq_question_number)
            if kq_id
                ef_id = _find_ef_id_by_kq_id(kq_id)
            end

            return ef_id
        end

        def _find_ef_id_by_kq_id(kq_id)  #{{{3
            ar_efkqs = ExtractionFormKeyQuestion.where(["key_question_id=?",
                                                           kq_id])
            if ar_efkqs.length > 1
                @listOf_errors_processing_rows << "Too many extraction form ids associated with key question id '#{kq_id}'"
                return nil
            elsif ar_efkqs.length == 1
                ef_id = ar_efkqs.first.extraction_form_id
                return ef_id
            else
                @listOf_errors_processing_rows << "Unable to match key question id '#{kq_id}' to extraction form ID."
                return nil
            end
        end

        def _verify_no_blank_column  #{{{3
            listOf_headers = @headers.keys
            if listOf_headers.include? nil
                @listOf_errors << "Workbook contains empty columns. Please remove empty columns before attempting again."
            end
        end

        def _verify_kq_in_row(row)  #{{{3
            listOf_headers = row.keys
            kq_candidates = listOf_headers.select { |h| h.match(/^['"]*k[ey]*[-_\s]*q[uestion'"]*$/i) }
            #if kq_candidates.length == 0
            #    @listOf_errors << "Workbook must contain exactly 1 'Key Question' column. 0 found."
            #elsif kq_candidates.length > 1
            #    @listOf_errors << "Workbook must contain exactly 1 'Key Question' column. More than 1 found."
            #else
            #    @kq_key = kq_candidates[0]
            #end
            if kq_candidates.length == 1
                @kq_key = kq_candidates[0]
            else
                @kq_key = -1
            end
        end

        def _find_study_identifier  #{{{3
            study_identifier = Array.new

            pmid_col = _find_pmid_column
            if pmid_col.length == 1
                @pmid_key = pmid_col[0]
                study_identifier << :pmid
            end

            internal_id_col = _find_internal_id_column
            if internal_id_col.length == 1
                @internal_id_key = internal_id_col[0]
                study_identifier << :internal_id
            end

            author_title_cols = _find_author_title_columns
            if author_title_cols
                study_identifier << :author_title
            end

            # Only return the first one.
            return study_identifier.first
        end

        def _find_pmid_column  #{{{3
            listOf_headers = @headers.keys
            pmid_candidates = listOf_headers.select { |h| h.match(/^['"]*pubmed[-_\s]*id['"]*$|^['"]*pmid['"]*$/i) }
            if pmid_candidates.length > 1
                @listOf_errors << "Workbook may contain at most 1 'PMID' column. More than 1 found."
            end
            pmid_candidates
        end

        def _find_internal_id_column  #{{{3
            listOf_headers = @headers.keys
            internal_id_candidates = listOf_headers.select { |h| h.match(/^['"]*internal[-_\s]*id['"]*$/i) }
            if internal_id_candidates.length > 1
                @listOf_errors << "Workbook may contain at most 1 'Internal ID' column. More than 1 found."
            end
            internal_id_candidates
        end

        def _find_author_title_columns  #{{{3
            listOf_headers = @headers.keys

            # Try to find author columns first
            author_candidates = listOf_headers.select { |h| h.match(/^['"]*author[s'"\s]*$/i) }
            if author_candidates.length > 1
                @listOf_errors << "Workbook may contain at most 1 'Author' column. More than 1 found."
            elsif author_candidates.length == 1
                study_title_candidates = listOf_headers.select { |h| h.match(/^['"]*study[-_\s]*title['"]*$|^['"]*title['"]*$/i) }
                if study_title_candidates.length > 1
                    @listOf_errors << "Workbook may contain at most 1 'Title' column. More than 1 found."
                elsif study_title_candidates.length == 1
                    @author_key, @study_title_key = author_candidates.first, study_title_candidates.first
                    return true
                end
            end

            # Try to find author_year columns
            author_year_candidates = listOf_headers.select { |h| h.match(/^['"]*author[s'"]*[-_\s,]*year['"]*$/i) }
            if author_year_candidates.length > 1
                @listOf_errors << "Workbook may contain at most 1 'Author, Year' column. More than 1 found."
            elsif author_year_candidates.length == 1
                study_title_candidates = listOf_headers.select { |h| h.match(/^['"]*study[-_\s]*title['"]*$|^['"]*title['"]*$/i) }
                if study_title_candidates.length > 1
                    @listOf_errors << "Workbook may contain at most 1 'Title' column. More than 1 found."
                elsif study_title_candidates.length == 1
                    @author_year_key, @study_title_key = author_year_candidates.first, study_title_candidates.first
                    return true
                end
            end

            return false
        end

        ### October 28, 2018: Here we are trying to find arm titles among columns
        def _find_arm_columns
            arm_candidates = listOf_headers.select { |h| h.match(/^Arm$/i) }
            if arm_candidates.length > 1
                @listOf_errors << "Workbook may contain at most 1 'Arm' column. More than 1 found."
            elsif arm_candidates.length == 1
              @arm_key = arm_candidates.first
            end
        end
end


class RubyXLImport < ImportHandler  #{{{1

    # @params [String] Path to file
    # @return [RubyXL::Workbook]
    def set_workbook(path)  #{{{2
        @local_file_path = path
        begin
            @wb = RubyXL::Parser.parse(@local_file_path)
        rescue RuntimeError=>e
            @listOf_errors << e
        end
        @wb
    end

    # The parsed data is returned in the form of an array of hashes,
    # where the keys of the hashes are the header values and the value
    # the cell content.
    # @params [RubyXL::Workbook]
    # @params [Array] Possible header strings
    # @return [Array of Hash]
    def parse_data(workbook, header_search=[])  #{{{2
        worksheet = workbook[0]
        raw_data = worksheet.extract_data
        if raw_data.length==0
            @listOf_errors << "Workbook might be empty."
            @data = []
        else
            @data = _transform_data(raw_data, header_search)
        end

        @headers = @data[0]
        @data = @data[1..-1]

        return @headers, @data
    end

    private  #{{{2
        # Transform the 2 dimensional array of values into
        # an array of header-value hashes
        # @params [nested Array]
        # @params [Array]
        # @return [Array of Hash]
        def _transform_data(raw_data, header_search=[])  #{{{3
            transformed_data = Array.new
            i = _find_header_row_index(raw_data, header_search)
            transformed_data << _transform_header_row(i, raw_data)
            transformed_data.concat(_transform_data_rows(i, raw_data))
            transformed_data
        end

        # @params [Integer]
        # @params [Array of Arrays]
        # @return [Hash]
        def _transform_header_row(i, raw_data)  #{{{3
            transformed_header_row = Hash.new
            raw_data[i].each do |key|
                if key.is_a? String
                    key = CGI.unescapeHTML(key).strip
                end
                transformed_header_row[key] = key
            end
            transformed_header_row
        end

        # Transform all rows except the header row into a list
        # of hashes, where the hash keys are the values of the
        # ith row
        # @params [Integer]
        # @params [Array of Arrays]
        # @return [Array of Hashes]
        def _transform_data_rows(i, raw_data)  #{{{3
            transformed_data_rows = Array.new
            headers = raw_data[i]
            raw_data.delete_at(i)
            raw_data.each do |row|
                transformed_row = Hash.new
                row.each_with_index do |c, ind|
                    if c.is_a? String
                        c = CGI.unescapeHTML(c).strip
                    end

                    key = headers[ind]
                    if key.is_a? String
                        key = CGI.unescapeHTML(key).strip
                    end
                    transformed_row[key] = c
                end
                transformed_data_rows << transformed_row
            end
            transformed_data_rows
        end

        def _find_header_row_index(raw_data, header_search=[])  #{{{3
            #!!! Use the strings in array header_search to
            #    find the row index of the header
            return 0
        end
end


class RooImport < ImportHandler  #{{{1

    # @params [String] Path to file
    # @return [Roo::Excelx]
    def set_workbook(path)  #{{{2
        @local_file_path = path
        @wb = Roo::Excelx.new(@local_file_path)
        return @wb
    end

    # The parsed data is returned in the form of an array of hashes,
    # where the keys of the hashes are the header values and the value
    # the cell content.
    # @params [Roo::Excelx]
    # @params [Array] Possible header strings
    #                 Regex allowed
    #                 Case insensitive
    # @return [Array of Hash]
    def parse_data(workbook, header_search=[])  #{{{2
        begin
            @data = workbook.parse(header_search: header_search, clean: true)
        rescue NoMethodError => e
            @listOf_errors << "Workbook might be empty. Following problem raised: #{e.message}."
            @data = []
            #puts e.message
            #puts e.backtrace.inspect
        else
            @data
            # other exception
        ensure
            # always executed
        end

        @headers = @data[0]
        @data = @data[1..-1]

        return @headers, @data
    end
end


class ImportSectionDetailHandler  #{{{1

    def initialize(section, ef_id, study_id, arm, arm_description, question, answer)  #{{{2
        @listOf_errors   = Array.new
        @section         = section
        @ef_id           = ef_id
        @study_id        = study_id
        @question        = question
        @answer          = answer
        @options         = nil
        @arm             = arm
        @arm_description = arm_description

    end

    def run  #{{{2
        question_type = _determine_question_type(@section, @question, @ef_id)

        case question_type
        when :checkbox
            _insert_checkbox_type(question_type)
        when :matrix_checkbox
            #!!! Need to implement
            _insert_matrix_checkbox_type(question_type)
        when :matrix_radio
            #!!! Need to implement
            _insert_matrix_radio_type(question_type)
        when :matrix_select
            #!!! Need to implement
            _insert_matrix_select_type(question_type)
        when :radio
            _insert_radio_type(question_type)
        when :select
            _insert_select_type(question_type)
        when :text
            _insert_text_type(question_type)
        end

        return @listOf_errors
    end

    private  #{{{2

        def _determine_question_type(section, q, ef_id)  #{{{3
            section_details = _find_section_details_with_equal(section, q, ef_id)
            if section_details.length == 1
                return section_details.first.field_type.to_sym
            elsif section_details.length > 1
                # This should never happen. There should never be the exact same question in the same section.
                @listOf_errors << "Failed to determine question type. Too many hits for question '#{q}' in extraction form id '#{ef_id}', section '#{section}'."
                return nil
            elsif section_details.length == 0
                # If search with equal and search with like returned nothing we conclude this is a
                # question that does not yet exist and default to :text type for creation.
                return :text
            end

            #section_details = _find_section_details_with_like(section, q, ef_id)
            #if section_details.length == 1
            #    return section_details.first.field_type.to_sym
            #elsif section_details.length > 1
            #    @listOf_errors << "Failed to determine question type. Too many hits for question '#{q}' in extraction form id '#{ef_id}', section '#{section}'."
            #    return nil
            #elsif section_details.length == 0
            #    # If search with equal and search with like returned nothing we conclude this is a
            #    # question that does not yet exist and default to :text type for creation.
            #    return :text
            #end
        end

        def _find_section_details_with_like(section, q, ef_id, question_type=nil)  #{{{3
            if question_type
                section_details = "#{section.to_s}".constantize.\
                    where(["question like ? AND extraction_form_id=? AND field_type=?",
                           "%#{q.strip}%", ef_id, question_type])
            else
                section_details = "#{section.to_s}".constantize.\
                    where(["question like ? AND extraction_form_id=?",
                           "%#{q.strip}%", ef_id])
            end
            return section_details
        end

        def _find_section_details_with_equal(section, q, ef_id, question_type=nil)  #{{{3
            if question_type
                section_details = "#{section.to_s}".constantize.\
                    where(["question=? AND extraction_form_id=? AND field_type=?",
                           q, ef_id, question_type])
            else
                section_details = "#{section.to_s}".constantize.\
                    where(["question=? AND extraction_form_id=?",
                           q, ef_id])
            end
            return section_details
        end

        # Find the section detail, e.g. a row in DesignDetail, with the question we are inserting
        # @params [Symbol]
        # @return [Boolean]
        def _insert_checkbox_type(question_type)  #{{{3
            sd = _find_section_detail(@section, @ef_id, @question, question_type)
            lof_selection, b_valid_selections = _validate_answer_selection(@section, sd)

            if b_valid_selections
                @options ||= _get_options_from_db(section, section_detail)
                include_selection, exclude_selection = _sort_answer_selection(@options, lof_selection)
                include_selection.each do |s|
                    _insert_data_point_mult(@section, sd, s, @study_id, @ef_id, arm=@arm, arm_description=@arm_description)
                end
                exclude_selection.each do |s|
                    _remove_data_point(@section, sd, s, @study_id, @ef_id, arm=@arm, arm_description=@arm_description)
                end
            else
                return false
            end
        end

        def _sort_answer_selection(options, selection)  #{{{3
            include_selection = Array.new
            exclude_selection = Array.new

            options.each do |opt|
                if selection.include? opt
                    include_selection << opt
                else
                    exclude_selection << opt
                end
            end

            return include_selection, exclude_selection
        end

        def _remove_data_point(section, section_detail, value, study_id, ef_id, arm=nil, arm_description=nil)  #{{{3
            ef_section_option_by_arm = EfSectionOption.\
              where(["extraction_form_id=? AND section=?",
                     ef_id, "arm_detail"]).first

            datapoints = [ ]

            if ef_section_option_by_arm and arm.present?
              arm_id = _find_arm_id(ef_id, arm, arm_description)
              datapoints = "#{section}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND value=? AND study_id=? AND extraction_form_id=? AND arm_id=?",
                         section_detail.id, value, study_id, ef_id, arm_id])

            else
              datapoints = "#{section}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND value=? AND study_id=? AND extraction_form_id=?",
                         section_detail.id, value, study_id, ef_id])
            end

            datapoints.each do |dp|
                dp.destroy
            end
        end

        def _insert_data_point_mult(section, section_detail, value, study_id, ef_id, arm=nil, arm_description=nil)  #{{{3
            ef_section_option_by_arm = EfSectionOption.\
              where(["extraction_form_id=? AND section=?",
                     ef_id, "arm_detail"]).first

            section_detail_data_points = [ ]
            arm_id = 0

            if ef_section_option_by_arm and arm.present?
              arm_id = _find_arm_id(ef_id, arm, arm_description)
              section_detail_data_points = "#{section.to_s}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND value=? AND study_id=? AND extraction_form_id=? AND arm_id=?",
                         section_detail.id, value, study_id, ef_id, arm_id])
            else
              section_detail_data_points = "#{section.to_s}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND value=? AND study_id=? AND extraction_form_id=?",
                         section_detail.id, value, study_id, ef_id])
            end

            if section_detail_data_points.length > 1
                @listOf_errors << "Found too many entries for #{section.to_s} data point. Answer choice '#{value}', ef ID '#{ef_id}', study id '#{study_id}'."
                return false
            elsif section_detail_data_points.length == 0
                if _create_section_detail_data_point(section, section_detail, value, study_id, ef_id)
                    return true
                else
                    return false
                end
            end
        end

        def _validate_answer_selection(section, section_detail)  #{{{3
            b_valid_selections = true
            cleaned_array = Array.new

            @options ||= _get_options_from_db(section, section_detail)

            selections = @answer.to_s.split(/`~`/)
            selections.each do |s|
                valid_option = @options.select { |opt| opt.match(/#{s}/) }
                if valid_option.length == 1
                    cleaned_array.concat valid_option
                elsif valid_option.length > 1
                    @listOf_errors << "Given answer selection '#{s}' matched too many answer choices."
                    b_valid_selections = false
                else
                    @listOf_errors << "Given answer selection '#{s}' matched no answer choices."
                    b_valid_selections = false
                end
            end

            return cleaned_array, b_valid_selections
        end

        def _insert_radio_type(question_type)  #{{{3
            sd = _find_section_detail(@section, @ef_id, @question, question_type)
            b_valid_choice, option = _valid_choice(@section, sd, @answer)
            if b_valid_choice
                return _insert_data_point(@section, sd, option, @study_id, @ef_id, arm=@arm, arm_description=@arm_description)
            else
                return false
            end
        end

        def _insert_select_type(question_type)  #{{{3
            sd = _find_section_detail(@section, @ef_id, @question, question_type)
            b_valid_choice, option = _valid_choice(@section, sd, @answer)
            if b_valid_choice
                return _insert_data_point(@section, sd, option, @study_id, @ef_id, arm=@arm, arm_description=@arm_description)
            else
                return false
            end
        end

        def _valid_choice(section, sd, selection)  #{{{3
            # Build an array of the options for this question from the database
            @options ||= _get_options_from_db(section, sd)

            # Match the selection against the options found in the database.
            valid_option = @options.select { |opt| opt.match(/#{selection}/) }

            if valid_option.length == 1
                return true, valid_option.first
            elsif valid_option.length > 1
                @listOf_errors << "Selection '#{selection}' appears to match more than 1 answer choice in escaped form for question '#{sd.question}'."
                return false
            else
                selection = CGI.unescapeHTML(selection.strip)
                valid_option = @options.select { |opt| opt.match(/#{selection}/) }
                if valid_option.length == 1
                    return true, valid_option.first
                elsif valid_option.length > 1
                    @listOf_errors << "Selection '#{selection}' appears to match more than 1 answer choice in unescaped form for question '#{sd.question}'."
                    return false
                else
                    @listOf_errors << "Selection '#{selection}' doesn't match any answer choice for question '#{sd.question}'."
                    return false
                end
            end
        end

        def _get_options_from_db(section, sd)  #{{{3
            section_detail_fields = "#{section.to_s}Field".constantize.\
                where(["#{section.to_s.underscore}_id=?", sd.id]).\
                select("option_text")

            # Build an array of the options
            options = section_detail_fields.map { |f| f.option_text }

            return options
        end

        def _insert_text_type(question_type)  #{{{3
            sd = _find_section_detail(@section, @ef_id, @question, question_type)
            b_success = _insert_data_point(@section, sd, @answer, @study_id, @ef_id, arm=@arm, arm_description=@arm_description)

            return b_success
        end

        def _insert_data_point(section, section_detail, answer, study_id, ef_id, arm=nil, arm_description=nil)  #{{{3
            ef_section_option_by_arm = EfSectionOption.\
              where(["extraction_form_id=? AND section=?",
                     ef_id, "arm_detail"]).first

            section_detail_data_points = [ ]
            arm_id = 0

            if ef_section_option_by_arm and arm.present?
              arm_id = _find_arm_id(ef_id, arm, arm_description)
              section_detail_data_points = "#{section.to_s}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND study_id=? AND extraction_form_id=? AND arm_id=?",
                         section_detail.id, study_id, ef_id, arm_id])
            else
              section_detail_data_points = "#{section.to_s}DataPoint".constantize.\
                  where(["#{section.to_s.underscore}_field_id=? AND study_id=? AND extraction_form_id=?",
                         section_detail.id, study_id, ef_id])
            end

            if section_detail_data_points.length > 1
                @listOf_errors << "Found too many entries for #{section.to_s} data point. Study id '#{study_id}' and ef ID '#{ef_id}'"
                return false
            elsif section_detail_data_points.length == 0
                if _create_section_detail_data_point(section, section_detail, answer, study_id, ef_id, 0, 0, arm_id)
                    return true
                else
                    return false
                end
            else
                return _update_section_detail_data_point(section_detail_data_points.first, answer)
            end
        end

        def _create_section_detail_data_point(section, section_detail,  #{{{3
                                              answer, study_id, ef_id,
                                              row_field_id=0, column_field_id=0,
                                              arm_id=0, outcome_id=0)
            "#{section.to_s}DataPoint".constantize.\
                create("#{section.to_s.underscore}_field_id".to_sym => section_detail.id,
                       value: answer,
                       study_id: study_id,
                       extraction_form_id: ef_id,
                       row_field_id: row_field_id,
                       column_field_id: column_field_id,
                       arm_id: arm_id,
                       outcome_id: outcome_id)
        end

        def _update_section_detail_data_point(section_detail_data_point, answer)  #{{{3
            section_detail_data_point.value = answer
            section_detail_data_point.save
        end

        def _find_section_detail(section, ef_id, q, question_type)  #{{{3
            # We are going to try to find the section detail in its html
            # escaped and unescaped form.
            # SRDR will save it to the database in its unescaped form

            # Try search with equal unmodified.
            section_details = _find_section_details_with_equal(section, q, ef_id, question_type)
            if section_details.length == 1
                return section_details.first
            elsif section_details.length > 1
                # This should never happen. There should never be the exact same question in the same section.
                @listOf_errors << "Found more than 1 #{section.to_s} that matched the question '#{q}' exactly, extraction form ID '#{ef_id}' and field type '#{question_type}'"
                return nil
            end

            # Try search with equal unescapedHTML.
            section_details = _find_section_details_with_equal(section, CGI.unescapeHTML(q), ef_id, question_type)
            if section_details.length == 1
                return section_details.first
            elsif section_details.length > 1
                # This should never happen. There should never be the exact same question in the same section.
                @listOf_errors << "Found more than 1 #{section.to_s} that matched the question '#{q}' exactly unescaped, extraction form ID '#{ef_id}' and field type '#{question_type}'"
                return nil
            end

            ## Try search with like unmodified.
            #section_details = _find_section_details_with_like(section, q, ef_id, question_type)
            #if section_details.length == 1
            #    return section_details.first
            #elsif section_details.length > 1
            #    # This should never happen. There should never be the exact same question in the same section.
            #    @listOf_errors << "Found more than 1 #{section.to_s} that matched the question '#{q}' with like, extraction form ID '#{ef_id}' and field type '#{question_type}'"
            #    return nil
            #end

            ## Try search with like unescapedHTML.
            #section_details = _find_section_details_with_like(section, CGI.unescapeHTML(q), ef_id, question_type)
            #if section_details.length == 1
            #    return section_details.first
            #elsif section_details.length > 1
            #    # This should never happen. There should never be the exact same question in the same section.
            #    @listOf_errors << "Found more than 1 #{section.to_s} that matched the question '#{q}' with like unescaped, extraction form ID '#{ef_id}' and field type '#{question_type}'"
            #    return nil
            #end

            # We are left with creating the section detail.
            section_detail = _create_section_detail(section, ef_id, q, question_type)
            return section_detail
        end

        def _create_section_detail(section, ef_id, q, question_type)  #{{{3
            # Place this question in the right order
            question_number = "#{section.to_s}".constantize.\
                where(["extraction_form_id=?", ef_id]).length + 1
            section_detail = "#{section.to_s}".constantize\
                .create(question: q,
                        extraction_form_id: ef_id,
                        field_type: question_type,
                        question_number: question_number,
                        is_matrix: 0)

            return section_detail
        end

        def _find_arm_id(ef_id, arm_title, arm_description=nil)
            # Identify by @study_id, ef_id, title
            if arm_title.is_a? String
                arm_title = CGI.unescapeHTML(arm_title)
            end

            if arm_description.is_a? String
                arm_description = CGI.unescapeHTML(arm_description)
            end

            if arm_description
                arm = Arm.where(["study_id=? AND title=? AND description=? AND extraction_form_id=?",
                                 @study_id, arm_title, arm_description, ef_id])
            else
                arm = Arm.where(["study_id=? AND title=? AND extraction_form_id=?",
                            @study_id, arm_title, ef_id])
            end

            if arm.length == 1
                return arm.first.id
            elsif arm.length == 0
                count_existing_arms = Arm.where(["study_id=? AND extraction_form_id=?",
                                          @study_id, ef_id]).length
                arm = Arm.create(study_id: @study_id,
                                 title: arm_title,
                                 description: arm_description,
                                 display_number: count_existing_arms + 1,
                                 extraction_form_id: ef_id,
                                 is_suggested_by_admin: 0,
                                 is_intention_to_treat: 1
                      )
                return arm.id
            else
                @listOf_errors << "Too many arms found with parameters: study_id=#{@study_id}, arm_title=#{arm_title}, ef_id#{ef_id}"
                return nil
            end
        end
end


class ImportAdverseEventHandler  #{{{1

    def initialize(section, ef_id, study_id, question, answer)  #{{{2
        @listOf_errors = Array.new
        @section       = section
        @ef_id         = ef_id
        @study_id      = study_id
        @question      = question
        @answer        = answer
        @options       = nil
    end

    def run(ae_title=nil, ae_description=nil, ae_arm=nil, ae_arm_description=nil)  #{{{2
        _insert_adverse_event(ae_title, ae_description, ae_arm, ae_arm_description)
        return @listOf_errors
    end

    private  #{{{2

        def _insert_adverse_event(ae_title, ae_description, ae_arm, ae_arm_description)  #{{{3
            ar_ae = _find_adverse_event(@section, @study_id, @ef_id, ae_title, ae_description)
            if ar_ae
                ar_aec = _find_adverse_event_column(@section, @question, @ef_id)
                if ar_aec
                    # This is what the data points are called.
                    _update_or_create_adverse_event_result(@section, ar_aec, ar_ae, @answer, @ef_id, ae_arm, ae_arm_description)
                end
            end
        end

        def _update_or_create_adverse_event_result(section, ae_column, ae, value, ef_id, ae_arm, ae_arm_description)  #{{{3
            ar_aer = _find_adverse_event_result(section, ae_column, ae, ef_id, ae_arm, ae_arm_description)
            if ar_aer
                ar_aer.value = value
                return ar_aer.save
            else
                return nil
            end
        end

        def _find_adverse_event_result(section, ae_column, ae, ef_id, ae_arm, ae_arm_description)  #{{{3
            # If ae_arm is given then we find the arm ID
            if ae_arm && ae_arm_description
                arm_id = _find_arm_id(ef_id, ae_arm, ae_arm_description)
            elsif ae_arm
                arm_id = _find_arm_id(ef_id, ae_arm)
            else
                arm_id = -1;
            end

            if arm_id.nil?
                return nil
            end

            ar_aer = "#{section.to_s}Result".constantize.\
                where(["column_id=? AND adverse_event_id=? AND arm_id=?",
                       ae_column.id, ae.id, arm_id])
            if ar_aer.length == 1
                return ar_aer.first
            elsif ar_aer.length > 1
                @listOf_errors << "Too many adverse event results found for AE '#{ae}', AE column '#{ae_column}' and arm ID '#{arm_id}'."
                return nil
            else
                ar_aer = "#{section.to_s}Result".constantize.\
                    create(column_id: ae_column.id,
                           value: "",
                           adverse_event_id: ae.id,
                           arm_id: arm_id)
                return ar_aer
            end
        end

        def _find_arm_id(ef_id, arm_title, arm_description=nil)
            # Identify by @study_id, ef_id, title
            if arm_title.is_a? String
                arm_title = CGI.unescapeHTML(arm_title)
            end

            if arm_description.is_a? String
                arm_description = CGI.unescapeHTML(arm_description)
            end

            if arm_description
                arm = Arm.where(["study_id=? AND title=? AND description=? AND extraction_form_id=?",
                                 @study_id, arm_title, arm_description, ef_id])
            else
                arm = Arm.where(["study_id=? AND title=? AND extraction_form_id=?",
                            @study_id, arm_title, ef_id])
            end

            if arm.length == 1
                return arm.first.id
            elsif arm.length == 0
                count_existing_arms = Arm.where(["study_id=? AND extraction_form_id=?",
                                          @study_id, ef_id]).length
                arm = Arm.create(study_id: @study_id,
                                 title: arm_title,
                                 description: arm_description,
                                 display_number: count_existing_arms + 1,
                                 extraction_form_id: ef_id,
                                 is_suggested_by_admin: 0,
                                 is_intention_to_treat: 1
                      )
                return arm.id
            else
                @listOf_errors << "Too many arms found with parameters: study_id=#{@study_id}, arm_title=#{arm_title}, ef_id#{ef_id}"
                return nil
            end
        end

        def _find_adverse_event_column(section, name, ef_id)  #{{{3
            if name.is_a? String
                unescaped_name = CGI.unescapeHTML(name)
            else
                unescaped_name = name
            end

            ar_aec = "#{section.to_s}Column".constantize.\
                where(["name=? AND extraction_form_id=?",
                       name, ef_id])
            if ar_aec.length == 1
                return ar_aec.first
            elsif ar_aec.length > 1
                @listOf_errors << "Too many columns matched the given name '#{name}' escaped and using equal."
                return nil
            end

            ar_aec = "#{section.to_s}Column".constantize.\
                where(["name=? AND extraction_form_id=?",
                       unescaped_name, ef_id])
            if ar_aec.length == 1
                return ar_aec.first
            elsif ar_aec.length > 1
                @listOf_errors << "Too many columns matched the given name '#{name}' unescaped and using equal."
                return nil
            end

            #ar_aec = "#{section.to_s}Column".constantize.\
            #    where(["name like ? AND extraction_form_id=?",
            #           "%#{name}%", ef_id])
            #if ar_aec.length == 1
            #    return ar_aec.first
            #elsif ar_aec.length > 1
            #    @listOf_errors << "Too many columns matched the given name '#{name}' escaped and using like."
            #    return nil
            #end

            #ar_aec = "#{section.to_s}Column".constantize.\
            #    where(["name like ? AND extraction_form_id=?",
            #           "%#{unescaped_name}%", ef_id])
            #if ar_aec.length == 1
            #    return ar_aec.first
            #elsif ar_aec.length > 1
            #    @listOf_errors << "Too many columns matched the given name '#{name}' unescaped and using like."
            #    return nil
            #end

            ar_aec = _create_adverse_event_column(section, unescaped_name, ef_id)
            return ar_aec
        end

        def _create_adverse_event_column(section, name, ef_id)  #{{{3
            ar_aec = "#{section.to_s}Column".constantize.\
                create(name: name,
                       extraction_form_id: ef_id)
            return ar_aec
        end

        def _find_adverse_event(section, study_id, ef_id, ae_title, ae_description)  #{{{3
            if ae_title && ae_description
                ar_aes = "#{section.to_s}".constantize.where(["study_id=? AND extraction_form_id=? AND title=? AND description=?",
                                                              study_id, ef_id, ae_title, ae_description])
            elsif ae_title
                ar_aes = "#{section.to_s}".constantize.where(["study_id=? AND extraction_form_id=? AND title=?",
                                                             study_id, ef_id, ae_title])
            else
                ar_aes = "#{section.to_s}".constantize.where(["study_id=? AND extraction_form_id=?",
                                                             study_id, ef_id])
            end
            if ar_aes.length == 1
                # Update the description in case it has changed.
                ar_ae = ar_aes.first
                ar_ae.description = ae_description
                ar_ae.save

                return ar_ae
            elsif ar_aes.length == 0
                ar_ae = _create_adverse_event(section, study_id, ef_id, ae_title, ae_description)
                return ar_ae
            else
                @listOf_errors << "Too many adverse events found for study id '#{study_id}' and extraction form id '#{ef_id}'."
                return nil
            end
        end

        def _create_adverse_event(section, study_id, ef_id, ae_title, ae_description)  #{{{3
            ar_ae = "#{section.to_s}".constantize.\
                create(study_id: study_id,
                       extraction_form_id: ef_id,
                       title: ae_title,
                       description: ae_description)
            return ar_ae
        end
end


class ImportArmHandler  #{{{1
    def initialize(section, ef_id, study_id, q_hash)  #{{{2
        @listOf_errors   = Array.new
        @section         = section
        @ef_id           = ef_id
        @study_id        = study_id
        @q_hash          = q_hash
        @arm             = nil
        @arm_description = nil
        @options         = nil
    end

    def run  #{{{2
        # Arm section only requires 1 entry: Arm
        # Arm description is optional
        _get_arm_info

        if @arm.blank?
            @listOf_errors << "Arm name is blank. Nothing to do"
            return @listOf_errors
        end

        _process_arm

        return @listOf_errors
    end

    private

        def _get_arm_info  #{{{3
            @q_hash.each do |q, a|
                case q
                when /^arms?$|^interventions?$|^groups?$/i
                    @arm = a
                when /^arm[-_\s]?descriptions?$/i
                    @arm_description = a
                else
                    @listOf_errors << "Found extra columns while processing Arm import. Column: #{q}"
                end
            end
        end

        def _process_arm  #{{{3
            # If potentially nil then we need to use a hash
            arm = Arm.where({ study_id: @study_id, title: @arm, description: @arm_description,
                              extraction_form_id: @ef_id }).first
            #arm = Arm.where(["study_id=? AND title=? AND description=? AND extraction_form_id=?",
            #                 @study_id, @arm, @arm_description, @ef_id]).first

            unless arm
                arm = _create_arm
            end
        end

        def _create_arm  #{{{3
            number_of_arms = _find_number_of_arms_already_in_study
            arm = Arm.create(study_id:           @study_id,
                             title:              @arm,
                             description:        @arm_description,
                             display_number:     number_of_arms + 1,
                             extraction_form_id: @ef_id)
        end

        def _find_number_of_arms_already_in_study  #{{{3
            arms = Arm.where(["study_id=? AND extraction_form_id=?",
                              @study_id, @ef_id])
            arms.length
        end
end


class ImportOutcomeHandler  #{{{1
    def initialize(section, ef_id, study_id, q_hash)  #{{{2
        @listOf_errors                = Array.new
        @section                      = section
        @ef_id                        = ef_id
        @study_id                     = study_id
        @q_hash                       = q_hash
        @options                      = nil
        @outcome_name                 = nil
        @outcome_description          = nil
        @outcome_type                 = nil
        @outcome_unit                 = nil
        @outcome_timepoint            = nil
        @outcome_timepoint_unit       = nil
        @outcome_subgroup             = nil
        @outcome_subgroup_description = nil
        @outcome_note                 = nil
    end

    def run  #{{{2
        _get_outcome_info

        if @outcome_name.blank?
            @listOf_errors << "Outcome name is blank. Nothing to do"
            return @listOf_errors
        end

        outcome = _process_outcome
        if outcome
            _process_timepoint(outcome)
            _process_subgroup(outcome)
        end

        return @listOf_errors
    end

    private  #{{{2

        def _get_outcome_info  #{{{3
            @q_hash.each do |q, a|
                case q
                when /^outcomes?$|^endpoints?$/i
                    @outcome_name = a
                when /^outcome[-_\s]?descriptions?$/i
                    @outcome_description = a
                when /^types?$/i
                    @outcome_type = a
                when /^unit[\(\)s]*$/i
                    @outcome_unit = a
                when /^timepoint[\(\)s]*$/i
                    @outcome_timepoint = a
                when /^timepoint\s?unit[\(\)s]*$/i
                    @outcome_timepoint_unit = a
                when /^subgroup[\(\)s]*$/i
                    @outcome_subgroup = a
                when /^subgroup[\(\)s]*[-_\s]?descriptions?$/i
                    @outcome_subgroup_description = a
                when /^notes?$/i
                    @outcome_note = a
                else
                    @listOf_errors << "Found extra columns while processing Outcome import. Column: #{q}"
                end
            end
        end

        def _process_outcome  #{{{3
            outcome = Outcome.where({ study_id: @study_id, title: @outcome_name, description: @outcome_description, extraction_form_id: @ef_id }).first

            unless outcome
                outcome = _create_outcome
            end

            outcome.description = @outcome_description
            outcome.units = @outcome_unit
            outcome.notes = @outcome_note
            outcome.outcome_type = @outcome_type
            outcome.save

            return outcome
        end

        def _create_outcome  #{{{3
            outcome = Outcome.create(study_id:           @study_id,
                                     title:              @outcome_name,
                                     is_primary:         1,
                                     units:              @outcome_unit,
                                     description:        @outcome_description,
                                     notes:              @outcome_note,
                                     outcome_type:       @outcome_type,
                                     extraction_form_id: @ef_id)
            return outcome
        end

        def _process_timepoint(outcome)  #{{{3
            # Look at app/controllers/outcomes_controller.rb to see what else is necessary.
            # Somehow I can't create a new outcome after import, maybe something is 
            # missing.
            _check_for_default_timepoint
            timepoint = _find_timepoint(outcome)
        end

        def _find_timepoint(outcome)  #{{{3
            outcome_timepoints = OutcomeTimepoint.where(outcome_id: outcome.id,
                                                        number: @outcome_timepoint,
                                                        time_unit: @outcome_timepoint_unit)
            if outcome_timepoints.length > 1
                @listOf_errors << "Too many timepoints for outcome_id '#{outcome.id}', timepoint '#{@outcome_timepoint}', unit '#{@outcome_timepoint_unit}'"
                return false
            elsif outcome_timepoints.length == 1
                return outcome_timepoints.first
            else
                outcome_timepoint = _create_outcome_timepoint(outcome)
                return outcome_timepoint
            end
        end

        def _create_outcome_timepoint(outcome)  #{{{3
            outcome_timepoint = OutcomeTimepoint.create(outcome_id: outcome.id,
                                                        number: @outcome_timepoint,
                                                        time_unit: @outcome_timepoint_unit)
            return outcome_timepoint
        end

        def _check_for_default_timepoint  #{{{3
            if @outcome_timepoint.blank?
                @outcome_timepoint = "Enter a numeric value or title (required)"
            end

            if @outcome_timepoint_unit.blank?
                @outcome_timepoint_unit = "years"
            end
        end

        def _process_subgroup(outcome)  #{{{3
            _check_for_default_subgroup
            subgroup = _find_subgroup(outcome)
        end

        def _find_subgroup(outcome)  #{{{3
            outcome_subgroups = OutcomeSubgroup.where(outcome_id: outcome.id,
                                                      title: @outcome_subgroup,
                                                      description: @outcome_subgroup_description)
            if outcome_subgroups.length > 1
                @listOf_errors << "Too many subgroups for outcome_id '#{outcome.id}', subgroup '#{@outcome_subgroup}', description '#{@outcome_subgroup_description}'"
                return false
            elsif outcome_subgroups.length == 1
                return outcome_subgroups.first
            else
                outcome_subgroup = _create_outcome_subgroup(outcome)
                return outcome_subgroup
            end
        end

        def _create_outcome_subgroup(outcome)  #{{{3
            outcome_subgroup = OutcomeSubgroup.create(outcome_id: outcome.id,
                                                      title: @outcome_subgroup,
                                                      description: @outcome_subgroup_description)
            return outcome_subgroup
        end

        def _check_for_default_subgroup  #{{{3
            if @outcome_subgroup.blank?
                @outcome_subgroup = "All Participants"
                if @outcome_subgroup_description.blank?
                    @outcome_subgroup_description = "All participants involved in the study (Default)"
                end
            end
        end
end











































