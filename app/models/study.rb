# == Schema Information
#
# Table name: studies
#
#  id                 :integer          not null, primary key
#  project_id         :integer
#  study_type         :string(255)
#  creator_id         :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# This class handles study functionality.
#
# A study belongs to a project, and is linked to the project by key questions.
# The data that is entered into a study is determined by the key questions it answers, which are linked to extraction forms.
class Study < ActiveRecord::Base
    belongs_to :project, :touch=>true
    #has_many :extraction_forms
    has_many :arms, :dependent=>:destroy
    has_many :outcome_results, :through => :outcomes
    has_many :outcome_timepoints, :through => :outcomes
    has_many :outcomes, :dependent=>:destroy
    has_many :outcome_data_entries, :dependent=>:destroy
    has_many :design_detail_data_points, :dependent=>:destroy
    has_many :arm_detail_data_points, :dependent=>:destroy
    has_many :baseline_characteristic_data_points, :dependent=>:destroy
    has_many :outcome_detail_data_points, :dependent=>:destroy
    has_many :adverse_event_arms, :through => :adverse_event
    has_many :adverse_events, :dependent=>:destroy
    has_many :secondary_publications, :dependent=>:destroy
    has_many :study_key_questions, :dependent=>:destroy
    has_many :key_questions, :through=>:study_key_questions
    has_many :study_extraction_forms, :dependent=>:destroy
    has_one :primary_publication, :dependent=>:destroy
    has_many :primary_publication_numbers, :through=>:primary_publication
    has_many :quality_dimension_data_points, :dependent=>:destroy
    has_many :quality_rating_data_points, :dependent=>:destroy
    has_many :baseline_characteristic_fields
    has_one :study_status_note, :dependent=>:destroy
    has_many :complete_study_sections, :dependent=>:destroy
    #has_many :user_studies, :dependent=>:destroy
    #has_many :users, :through=>:user_studies
    attr_accessible :study_type, :outcome_attributes, :creator_id, :extraction_form_id, :project_id

    require 'will_paginate/array'
    # creator
    # get the name of the person who created the study
    def creator
        usr = User.where(:id=>self.creator_id).select("login")
        return usr.empty? ? "Not Found" : usr.first.login
    end

    # get_sorted_for_project
    # collect the group of studies corresponding to a project and sort it depending on the sort parameter
    # Sort options are:
    # Creator (Alphabetical)
    # Date Created
    # Date Updated (Recent First)
    # Pubmed ID
    # First Author
    # Key Question
    # NOTE THAT THE STUDY IDS PARAMETER IS A COMMA SEPARATED LIST OF IDS
    #def self.get_sorted_for_project(projID, sortBy, pageNum, numPerPage, user_role, u_id)
    def self.get_sorted_study_list(projID, study_ids, sortBy, pageNum, numPerPage, user_role, u_id)
        begin
            #puts "\n\nSorting studies by #{sortBy}\n\n"
            retVal = nil
            users = []
            if user_role == 'lead'
                users = UserProjectRole.where(:project_id=>projID).select("user_id").collect{|x| x.user_id}.uniq
            elsif user_role == 'editor'
                users << u_id
            end
            case
            when sortBy == 'Default' then
                #puts "sorting by default"
                retVal = Study.where(:project_id => projID, :id=>study_ids, :creator_id=>users).order("id ASC").paginate(:page=>pageNum, :per_page => numPerPage)
            when sortBy == 'Creator' then
                #puts "sorting by creator"
                retVal = Study.find_by_sql("SELECT studies.*, users.login FROM studies INNER JOIN users on users.id = studies.creator_id where studies.project_id=#{projID} and studies.creator_id IN (#{users.join(',')}) AND studies.id IN (#{study_ids.join(',')}) order by users.login").paginate(:page=>pageNum,:per_page=>numPerPage)
            when sortBy == "Date Created" then
                #puts "sorting by date created"
                retVal = Study.where(:project_id=>projID, :id=>study_ids, :creator_id=>users).order("created_at ASC").paginate(:page=>pageNum,:per_page=>numPerPage)
            when sortBy == 'Date Updated (Recent First)' then
                #puts "sorting by date updated"
                retVal = Study.where(:project_id=>projID, :id=>study_ids, :creator_id=>users).order("updated_at DESC").paginate(:page=>pageNum,:per_page=>numPerPage)
            when sortBy == "Pubmed ID" then
                #puts "sorting by pubmed id"
                retVal = Study.find_by_sql("SELECT studies.*, primary_publications.pmid FROM studies INNER JOIN primary_publications on primary_publications.study_id = studies.id where studies.project_id=#{projID} AND studies.creator_id IN (#{users.join(',')}) AND studies.id IN (#{study_ids.join(',')}) ORDER BY IF(primary_publications.pmid = '' OR primary_publications.pmid IS NULL,1,0), primary_publications.pmid").paginate(:page=>pageNum,:per_page=>numPerPage)
            when sortBy == "First Author" then
                #puts "sorting first author"
                retVal = Study.find_by_sql("SELECT studies.*, primary_publications.author FROM studies INNER JOIN primary_publications on primary_publications.study_id = studies.id where studies.project_id=#{projID} AND studies.creator_id IN (#{users.join(',')}) AND studies.id IN (#{study_ids.join(',')}) order by LEFT(primary_publications.author,5)").paginate(:page=>pageNum,:per_page=>numPerPage)
            when sortBy.match(/^alternate_/) then
                which = sortBy.gsub("alternate_","")
                puts "sorting by alternate: #{which}"
                retVal = Study.find_by_sql("SELECT s.*, pp.study_id, pp.id, ppn.number, ppn.number_type FROM studies AS s INNER JOIN primary_publications AS pp ON s.id = pp.study_id, primary_publication_numbers AS ppn WHERE pp.id = ppn.primary_publication_id AND ppn.number_type='#{which}' AND s.creator_id IN (#{users.join(',')}) AND s.id IN (#{study_ids.join(',')}) ORDER BY IF(ppn.number = '' OR ppn.number IS NULL,1,0), ppn.number ASC").paginate(:page=>pageNum,:per_page=>numPerPage)

            else
                puts "hit the else clause!"
                retVal = Study.where(:project_id => projID, :id=>study_ids, :creator_id=>users).order("id ASC").paginate(:page=>pageNum, :per_page => numPerPage)
            end
            return retVal
        rescue Exception=>e
            puts "AN ERROR OCCURRED WHILE SORTING: #{e.message}\n\n#{e.backtrace}\n\n"
            return []
        end
    end

    # copy_project_studies
    # copy all studies associated with a particular project. Be sure to update associations
    # between studies and the extraction forms that they utilize for extraction.
    # @params [integer] user_id     - the user requesting the copy
    # @params [hash] ef_id_map      - a mapping between old and new extraction form IDs
    # @params [integer] old_proj_id - the original ID for the project being copied
    # @params [integer] new_proj_id - the ID of the newly created project
    # @params [boolean] copy_study_data  - whether or not extracted data should be copied
    # @params [hash] dd_id_map           - the mapping between old and new design details
    # @params [hash] dd_field_map           - the mapping between old and new design detail fields
    # @params [hash] bc_id_map           - the mapping between old and new baseline characteristics
    # @params [hash] bc_field_map           - the mapping between old and new baseline characteristic fields
    # @params [hash] ae_id_map           - the mapping between old and new adverse event columns
    # @return [hash] study_id_map   - a mapping between old and new study IDs
    def self.copy_project_studies(user_id, ef_id_map, kq_id_map, old_proj_id, new_proj_id, copy_study_data, ad_id_map, ad_field_map, dd_id_map, dd_field_map, bc_id_map, bc_field_map, od_id_map, od_field_map, ae_id_map, qual_id_map)
        # keep track of new study IDs after they're created. this information can be used later to
        # assign information extracted to the study
        study_id_map = Hash.new()
        arm_id_map = Hash.new()

        # get all studies associated with the project and iterate through them
        study_list = Project.get_studies(old_proj_id)
        study_list.each do |study|
            # create the study in the new project and record it in the study_id_map hash
            new_study = Study.create(:project_id=>new_proj_id, :creator_id=>user_id)
            study_id_map[study.id] = new_study.id

            # obtain primary publication information for the study and clone it
            ppub = study.get_primary_publication
            unless ppub.nil?
                new_ppub = ppub.clone
                new_ppub.study_id = new_study.id
                new_ppub.created_at = Time.now
                new_ppub.updated_at = Time.now
                new_ppub.save
            end

            # obtain secondary publication information for the study and clone it
            # NOTE - the extraction form ID parameter for this function is not necessary,
            # so I'm putting in 0 as a placeholder. Fix this eventually...
            spub = study.get_secondary_publications(0)
            spub.each do |pub|
                new_spub = pub.clone
                new_spub.study_id = new_study.id
                new_spub.created_at = Time.now
                new_spub.updated_at = Time.now
                new_spub.save
            end

            # set up the study key questions and study extraction forms tables
            old_entries = StudyKeyQuestion.where(:study_id=>study.id)
            covered_efs = Array.new()
            old_entries.each do |entry|
                # get the id of the cloned extraction form
                new_ef_id = ef_id_map[entry.extraction_form_id]
                # get the id of the cloned key question
                new_kq_id = kq_id_map[entry.key_question_id]

                StudyKeyQuestion.create(:study_id=>new_study.id, :key_question_id=>new_kq_id, :extraction_form_id=>new_ef_id)

                unless covered_efs.include?(entry.extraction_form_id)
                    ef_entries = StudyExtractionForm.where(:study_id=>study.id, :extraction_form_id=>entry.extraction_form_id)
                    ef_entries.each do |e|
                        new_e = e.clone
                        new_e.study_id = new_study.id
                        new_e.extraction_form_id = new_ef_id
                        new_e.save
                    end
                end
                covered_efs << entry.extraction_form_id
            end

            # If the user asked for extracted data as well, collect it
            ############################################################
            if copy_study_data
                # Arm data
                arms = Arm.where(:study_id=>study.id)
                arms.each do |arm|
                    new_arm = arm.clone
                    new_arm.study_id = new_study.id
                    new_arm.extraction_form_id = ef_id_map[arm.extraction_form_id]
                    new_arm.created_at = Time.now
                    new_arm.updated_at = Time.now
                    new_arm.save
                    arm_id_map[arm.id] = new_arm.id
                end
                # Arm Detail data
                ads = ArmDetailDataPoint.where(:study_id=>study.id)
                ads.each do |ad|
                    new_ad = ad.clone
                    new_ad.study_id = new_study.id
                    new_ad.extraction_form_id = ef_id_map[ad.extraction_form_id]
                    new_ad.arm_detail_field_id = ad_id_map[ad.arm_detail_field_id]
                    unless ad.arm_id == 0
                        new_ad.arm_id = arm_id_map[ad.arm_id]
                    end
                    unless new_ad.row_field_id.nil?
                        unless new_ad.row_field_id == 0
                            new_ad.row_field_id = ad_field_map[new_ad.row_field_id]
                        end
                        unless new_ad.column_field_id == 0
                            new_ad.column_field_id = ad_field_map[new_ad.column_field_id]
                        end
                    end
                    new_ad.created_at = Time.now
                    new_ad.updated_at = Time.now
                    new_ad.save
                end

                # Design Detail data
                dds = DesignDetailDataPoint.where(:study_id=>study.id)
                dds.each do |dd|
                    new_dd = dd.clone
                    new_dd.study_id = new_study.id
                    new_dd.extraction_form_id = ef_id_map[dd.extraction_form_id]
                    new_dd.design_detail_field_id = dd_id_map[dd.design_detail_field_id]
                    unless new_dd.row_field_id.nil?
                        unless new_dd.row_field_id == 0
                            new_dd.row_field_id = dd_field_map[new_dd.row_field_id]
                        end
                        unless new_dd.column_field_id == 0
                            new_dd.column_field_id = dd_field_map[new_dd.column_field_id]
                        end
                    end
                    new_dd.created_at = Time.now
                    new_dd.updated_at = Time.now
                    new_dd.save
                end

                # Baseline Characteristic data
                bcs = BaselineCharacteristicDataPoint.where(:study_id=>study.id)
                bcs.each do |bc|
                    new_bc = bc.clone
                    new_bc.study_id = new_study.id
                    new_bc.extraction_form_id = ef_id_map[bc.extraction_form_id]
                    new_bc.baseline_characteristic_field_id = bc_id_map[bc.baseline_characteristic_field_id]
                    unless bc.arm_id == 0
                        new_bc.arm_id = arm_id_map[bc.arm_id]
                    end
                    unless new_bc.row_field_id.nil?
                        unless new_bc.row_field_id == 0
                            new_bc.row_field_id = bc_field_map[new_bc.row_field_id]
                        end
                        unless new_bc.column_field_id == 0
                            new_bc.column_field_id = bc_field_map[new_bc.column_field_id]
                        end
                    end
                    new_bc.created_at = Time.now
                    new_bc.updated_at = Time.now
                    new_bc.save
                end

                # Design Detail data
                ods = OutcomeDetailDataPoint.where(:study_id=>study.id)
                ods.each do |od|
                    new_od = od.clone
                    new_od.study_id = new_study.id
                    new_od.extraction_form_id = ef_id_map[od.extraction_form_id]
                    new_od.outcome_detail_field_id = od_id_map[od.outcome_detail_field_id]
                    unless new_od.row_field_id.nil?
                        unless new_od.row_field_id == 0
                            new_od.row_field_id = od_field_map[new_od.row_field_id]
                        end
                        unless new_od.column_field_id == 0
                            new_od.column_field_id = od_field_map[new_od.column_field_id]
                        end
                    end
                    new_od.created_at = Time.now
                    new_od.updated_at = Time.now
                    new_od.save
                end

                # Outcome data
                outcomes = Outcome.where(:study_id=>study.id)
                outcomes.each do |oc|
                    new_oc = oc.clone
                    new_oc.study_id = new_study.id
                    new_oc.extraction_form_id = ef_id_map[oc.extraction_form_id]
                    new_oc.created_at = Time.now
                    new_oc.updated_at = Time.now
                    new_oc.save

                    octp_id_map = Hash.new
                    ocsg_id_map = Hash.new
                    # outcome timepoints
                    octps = OutcomeTimepoint.where(:outcome_id=>oc.id)
                    octps.each do |octp|
                        tmp_tp = OutcomeTimepoint.create(:outcome_id=>new_oc.id, :number=>octp.number, :time_unit=>octp.time_unit)
                        octp_id_map[octp.id] = tmp_tp.id
                    end
                    # outcome subgroups
                    ocsgs = OutcomeSubgroup.where(:outcome_id=>oc.id)
                    ocsgs.each do |ocsg|
                        tmp_sg = OutcomeSubgroup.create(:outcome_id=>new_oc.id, :title=>ocsg.title, :description=>ocsg.description)
                        ocsg_id_map[ocsg.id] = tmp_sg.id
                    end

                    # Outcome Results data
                    # Begin with outcome data entries
                    ocdes = OutcomeDataEntry.where(:outcome_id=>oc.id)
                    ocdes.each do |ocde|
                        new_ocde = ocde.clone
                        new_ocde.outcome_id = new_oc.id
                        new_ocde.extraction_form_id = ef_id_map[ocde.extraction_form_id]
                        new_ocde.timepoint_id = octp_id_map[ocde.timepoint_id]
                        new_ocde.study_id = new_study.id
                        new_ocde.subgroup_id = ocsg_id_map[ocde.subgroup_id]
                        new_ocde.save

                        # get outcome measures for this ocde
                        measures = OutcomeMeasure.where(:outcome_data_entry_id=>ocde.id)
                        measures.each do |m|
                            new_m = m.clone
                            new_m.outcome_data_entry_id = new_ocde.id
                            new_m.save

                            # get any data points for the measure
                            dps = OutcomeDataPoint.where(:outcome_measure_id=>m.id)
                            dps.each do |dp|
                                new_dp = dp.clone
                                new_dp.outcome_measure_id = new_m.id
                                new_dp.arm_id = arm_id_map[dp.arm_id]
                                new_dp.save
                            end

                        end
                    end
                    # Now for outcome comparisons
                    comparisons = Comparison.where(:outcome_id=>oc.id)
                    comparisons.each do |c|
                        new_c = c.clone
                        new_c.study_id = new_study.id
                        new_c.extraction_form_id = ef_id_map[c.extraction_form_id]
                        new_c.outcome_id = new_oc.id
                        if c.within_or_between == 'between'
                            new_c.group_id = octp_id_map[c.group_id]
                        end
                        new_c.subgroup_id = ocsg_id_map[c.subgroup_id]
                        new_c.save

                        comparator_id_map = Hash.new
                        # get comparators
                        comps = Comparator.where(:comparison_id => c.id)
                        comps.each do |comp|
                            # create the appropriate new comparator string
                            string_ids = comp.comparator.split("_")
                            new_string = ""
                            string_ids.each do |sid|
                                new_id = 0
                                if c.within_or_between == 'between'
                                    new_id = arm_id_map[sid.to_i]
                                elsif c.within_or_between == 'within'
                                    new_id = octp_id_map[sid.to_i]
                                end
                                new_string += new_id.to_s
                                unless string_ids.index(sid) == string_ids.length-1
                                    new_string += "_"
                                end
                            end
                            tmp_comp = Comparator.create(:comparison_id => new_c.id, :comparator => new_string)
                            comparator_id_map[comp.id] = tmp_comp.id
                        end

                        # get comparison measures
                        cmeasures = ComparisonMeasure.where(:comparison_id=>c.id)
                        cmeasures.each do |cmeas|
                            new_cmeas = cmeas.clone
                            new_cmeas.comparison_id = new_c.id
                            new_cmeas.save

                            # copy any existing data points
                            dps = ComparisonDataPoint.where(:comparison_measure_id=>cmeas.id)
                            dps.each do |dp|
                                new_dp = dp.clone
                                new_dp.comparison_measure_id = new_cmeas.id
                                new_dp.comparator_id = comparator_id_map[dp.comparator_id]
                                unless dp.arm_id == 0
                                    new_dp.arm_id = arm_id_map[dp.arm_id]
                                end
                                new_dp.save
                            end
                        end
                    end


                end

                # Adverse Event data
                aes = AdverseEvent.where(:study_id=>study.id)
                aes.each do |ae|
                    new_ae = ae.clone
                    new_ae.study_id = new_study.id
                    new_ae.extraction_form_id = ef_id_map[ae.extraction_form_id]
                    new_ae.created_at = Time.now
                    new_ae.updated_at = Time.now
                    new_ae.save
                    # include the adverse event results
                    ae_results = AdverseEventResult.where(:adverse_event_id => ae.id)
                    ae_results.each do |aer|
                        new_aer = aer.clone
                        new_aer.adverse_event_id = new_ae.id
                        new_aer.column_id = ae_id_map[aer.column_id]
                        unless aer.arm_id == -1
                            new_aer.arm_id = arm_id_map[aer.arm_id]
                        end
                        new_aer.created_at = Time.now
                        new_aer.updated_at = Time.now
                        new_aer.save
                    end
                end

                # Quality Dimension data
                q_dimensions = QualityDimensionDataPoint.where(:study_id=>study.id)
                q_dimensions.each do |qd|
                    new_qd = QualityDimensionDataPoint.create(:quality_dimension_field_id=>qual_id_map[qd.quality_dimension_field_id],
                                                              :value=>qd.value, :notes=>qd.notes, :study_id=>new_study.id,
                                                              :field_type=>qd.field_type, :extraction_form_id=>ef_id_map[qd.extraction_form_id])
                end

                # Quality Rating Data
                q_ratings = QualityRatingDataPoint.where(:study_id=>study.id)
                q_ratings.each do |qr|
                    new_qr = QualityRatingDataPoint.create(:study_id=>new_study.id, :guideline_used=>qr.guideline_used,
                                                           :current_overall_rating=>qr.current_overall_rating,
                                                           :notes=>qr.notes,:extraction_form_id=>ef_id_map[qr.extraction_form_id])
                end
            end
        end # end studies.each do |study|
        return study_id_map
    end

    # Return an array of available extraction_forms for a particular project. This is obtained based on
    # the extraction forms associated with the given project_id.
    #
    # @param [Integer] project_id    the id of the project containing the study
    # @return [Array] arr          an array containing title and id of the extraction_form
    def self.get_extraction_form_list_array(project_id)
        arr = []
        extraction_forms = ExtractionForm.where(:project_id=>project_id).all
        extraction_forms.each do |extraction_form|
            arr << [extraction_form.title, extraction_form.id]
        end
        return arr
    end

    # get an array of extraction forms that are associated with a study
    # @return [array] array of extraction forms
    def get_extraction_forms
        id_list = StudyExtractionForm.where(:study_id=>self.id).select("extraction_form_id")
        forms = []
        unless id_list.empty?
            id_list.each do |ef_obj|
                tmp = ExtractionForm.find(ef_obj.extraction_form_id)
                unless tmp.nil?
                    forms << tmp
                end
            end
        end
        return forms
    end
    # get the pubmed ID of the study
    def get_pubmed_id
        pub = PrimaryPublication.where(:study_id=>self.id).select('pmid');
        if pub.empty?
            return ""
        else
            return pub.first.pmid
        end
    end

    # get_first_author
    # retrieve the first author of the study
    def get_first_author
        retVal = ""
        prim_pub = PrimaryPublication.where(:study_id=>self.id).select("author")
        #puts "The length of the primary publications is #{prim_pub.length}"
        unless prim_pub.empty?
            #puts "The primary publication is not empty.\n\n"
            prim_pub = prim_pub.first
            unless prim_pub.author.nil?
                #puts "The primary publication author is not nil.\n\n"
                unless prim_pub.author.empty?
                    #puts "The primary publication author is not empty.\n\n"
                    retVal = prim_pub.author.split(",")[0]
                    #puts "The primary publication author is #{prim_pub.author}\n\n"
                end
            end
        end
        return retVal
    end

    # return a citation representing the current study
    def get_citation(alt_ids = [])
        retVal = ""
        arr = Study.get_key_question_output(self.id)
        study_pub_info = Study.get_primary_pub_info(self.id)

        # List the Pubmed ID
        retVal += "<strong>PubMed ID:</strong> #{study_pub_info.pmid.nil? ? "None" : study_pub_info.pmid.empty? ? "None" : study_pub_info.pmid}"

        # Include any alternate identifiers
        alt_ids.each do |aid|
            retVal += " | <strong>#{aid.number_type == 'internal' ? 'Internal ID' : aid.number_type}:</strong> #{aid.number} "
        end

        # Include the rest of the study citation, Title, Author, Year, etc.
        retVal += "<br/>#{study_pub_info.author}. <strong>#{study_pub_info.title.nil? ? 'Untitled' : study_pub_info.title}.</strong>
                   <em>#{study_pub_info.journal}</em> #{ study_pub_info.year }. <strong>Vol.</strong> #{ study_pub_info.volume }
                    <strong>Issue</strong> #{ study_pub_info.issue }<br/><br/>
                    <strong>Assigned User: </strong> #{self.get_study_creator }&nbsp;&nbsp;|&nbsp;&nbsp;
                    <strong>Key Questions Answered:</strong> #{ arr.sort.to_sentence }&nbsp;&nbsp;|&nbsp;&nbsp;
                    <strong>Created:</strong> #{self.created_at.strftime("%B %d, %Y")}&nbsp;&nbsp;|&nbsp;&nbsp;
                    <strong>Last Updated:</strong> #{self.updated_at.strftime('%B %d, %Y')}"
                    return retVal
    end
    # assign key questions to a study.
    # if they already exist, don't worry about saving.
    # Then, remove any existing entries that are out-of-date.
    # @param [array] questions the key question IDs to assign to a study
    # @param [integer] ef_id the extraction form id (not actually used in the function...)
    def assign_questions(questions, ef_id)
        # compare new key question (extraction form) assignments with old assignments. 
        orig_kq_assignments = StudyKeyQuestion.find(:all, :conditions=>["study_id=?",self.id],:select=>["id","study_id","key_question_id","extraction_form_id"])
        orig_kqs = orig_kq_assignments.collect{|x| x.key_question_id}.uniq
        orig_efs = orig_kq_assignments.collect{|x| x.extraction_form_id}.uniq
        new_kq_assignments = ExtractionFormKeyQuestion.find(:all, :conditions=>["key_question_id IN (?)",questions],:select=>["extraction_form_id","key_question_id"])
        new_kqs = new_kq_assignments.collect{|x| x.key_question_id}.uniq
        new_efs = new_kq_assignments.collect{|x| x.extraction_form_id}.uniq

        # Check the new key question assignments, and add them if they aren't already there. 
        new_kq_assignments.each do |efkq|
            # add an entry for the study key question unless it's already defined.
            unless orig_kqs.include?(efkq.key_question_id)
                StudyKeyQuestion.create(:study_id=>self.id, :key_question_id=>efkq.key_question_id, :extraction_form_id=>efkq.extraction_form_id)
                unless orig_efs.include?(efkq.extraction_form_id) 
                    StudyExtractionForm.create(:study_id=>self.id, :extraction_form_id=>efkq.extraction_form_id)
                    orig_efs << efkq.extraction_form_id
                end
            end
        end

        # Now loop through the existing study_key_question assignments and remove them if they don't belong.
        efs_to_unassign = []
        orig_kq_assignments.each do |okq|
            unless new_kqs.include?(okq.key_question_id)
                unless new_efs.include?(okq.extraction_form_id) || efs_to_unassign.include?(okq.extraction_form_id)
                    efs_to_unassign << okq.extraction_form_id 
                end
                StudyKeyQuestion.destroy(okq.id)
            end
        end
        
        # Now remove any study_extraction_forms entries that are no longer going to be used.        
        efs_to_unassign.each do |u|
            #ExtractionForm.remove_extracted_data(u, self.id)
            CompleteStudySection.clear_entries_for_study_form(self.id, u)
        end
        to_unassign = StudyExtractionForm.find(:all, :conditions=>["study_id=? AND extraction_form_id IN (?)",self.id, efs_to_unassign], :select=>[:id])
        to_unassign = to_unassign.collect{|x| x.id}
        StudyExtractionForm.destroy(to_unassign)       
    end

    # test if a value is in the given array
    # @param [integer] val the value to test
    # @param [array] arr the array to test
    # @return [boolean] whether the value is in the array
    def self.is_value_in_array(val, arr)
        retVal = false
        for i in 0..arr.length-1
            if val.to_s == arr[i].to_s
                retVal = true
            end
        end
        return retVal
    end
    
    # get arms for a study
    # @param [integer] study_id
    # @return [array] arms array
    def self.get_arms(study_id)
        return Arm.where(:study_id => study_id).order("display_number ASC")
    end
    
    # get outcomes for a study
    # @param [integer] study_id
    # @return [array] outcomes array    
    def self.get_outcomes(study_id)
        return Outcome.where(:study_id => study_id).all
    end
    
    # get the questions for a project
    # @param [integer] project_id
    # @return [array] key questions array
    def get_question_choices(project_id)
        questions = KeyQuestion.find(:all, :order => "question_number ASC", :conditions => ["project_id = ?", project_id])
        return(questions)
    end

    # get the key questions that are addressed by the extraction form given
    # @param [integer] ef_id extraction form id
    # @return [array] key questions array
    def get_questions_addressed(ef_id)
        
        questions_array = Array.new
        question_ids = StudyKeyQuestion.where(:study_id=>self.id, :extraction_form_id => ef_id)
        unless(question_ids.empty?)
              question_ids.each do |q_hash|
                question_info = KeyQuestion.find(q_hash["key_question_id"], :select=>["id","question_number","question"])
                  questions_array.push([question_info.id, question_info.question_number, question_info.question])
                end
        end
        return (questions_array)
    end
    
    # given an array of studies, return another array of formatted 
    # strings that show the questions addressed for each study.
    # example: "1, 3 and 4"
    # @param [array] studies array of studies to get questions for
    # @return [array] formatted array of strings
    def self.get_addressed_question_numbers_for_studies(studies)
            return_array = Array.new

            studies.each do |study|
                questions = Array.new
                q_addressed = StudyKeyQuestion.where(:study_id=>study.id)
                                
                q_addressed.each do |q|
                  questions << KeyQuestion.where(:id=>q.key_question_id)[0]
                end
                return_array << KeyQuestion.format_for_display(questions)
         end
         return return_array
    end
    
    # get an array of the ids only of the key questions addressed by the extraction form
    # @param [integer] ef_id extraction form id
    # @return [array] an array of kq ids
    def get_addressed_ids(ef_id)
        ids_only = Array.new
        questions = get_questions_addressed(ef_id)
        questions.each do |q|
          ids_only.push(q[0])   
        end
        return ids_only
    end
    
    # when study is deleted, remove any associations with the key questions.
    # THIS FUNCTION IS IMPLEMENTED TWICE    
    def remove_from_junction
        entries = StudyKeyQuestion.where(:study_id => self.id)
        unless entries.empty?
            entries.each do |entry|
                entry.destroy
            end
        end
    end
    
    # get the primary publication for a study. used for getting title and basic info for the citation partial. 
    # a study only has one primary publication, and the title of the primary pub is the title of the study.
    # @return [PrimaryPublication] primary publication
    def get_primary_publication
      primary = PrimaryPublication.find(:first, :conditions => ["study_id = ?", self.id])
      return primary
    end  
    
    # get the secondary publications list for a study. This function may not be being used.
    # @param [integer] ef_id extraction form id - not actually used in the function
    # @return [array] secondary publications array
    def get_secondary_publications(ef_id)
        secondary = SecondaryPublication.find(:all, :order => 'display_number ASC', :conditions => ["study_id = ?", self.id])
        return secondary
    end
    
    # return an array of study titles, which are taken from the title
    # of the primary publication associated with that study
    # @param [array] studies an array of studies to get titles for
    # @return [array] an array of study titles
    def self.get_ui_title_author_year(studies)
        sql = ActiveRecord::Base.connection()
        titles = []
        if !studies.nil?
            studies.each do |study|
                tmp = PrimaryPublication.where(:study_id => study.id).first
                tmp0 = []
                tmp0 << tmp.ui
                tmp0 << tmp.title
                tmp0 << tmp.author
                tmp0 << tmp.year
                titles << tmp0
            end
        end
        return(titles)
    end
    
    # return the primary publication object for the study, and if it does not exist then
    # create a temporary one with some default information filled in
    # THIS CAN LIKELY BE MERGED WITH GET_PRIMARY_PUBLICATION
    # @param [integer] study_id the study id to get the primary publication for
    # @return [PrimaryPublication] the primary publication of the study.
    def self.get_primary_pub_info(study_id)
            tmp = PrimaryPublication.where(:study_id => study_id).first
            if tmp.nil?
                tmppub = PrimaryPublication.new
                tmppub.title = "Not Entered Yet"
                tmppub.author = "-"
                tmppub.year = "-"
                tmppub.country = "-"
                return tmppub
            else
                return tmp
            end 
    end
    
    # get the study title based on the id - via the primary publication
    # @param [integer] study_id
    # @return [string] the study title
    def self.get_title(study_id)
            tmp = PrimaryPublication.where(:study_id => study_id).first
            if tmp.nil?
                return "Not Entered Yet"
            else
                return tmp.title
            end 
    end 
    
    # get an array of key questions and their question numbers for a particular study
    # @param [integer] study_id
    # @return [array] key questions and key question numbers for the study
    def self.get_key_question_output(study_id)
        @s_keyqs = StudyKeyQuestion.where(:study_id => study_id).all
        @keyqs = []

        for k in @s_keyqs
            @keyqs << KeyQuestion.find(k.key_question_id)
        end

        arr = []
        for q in @keyqs
            arr << q.question_number.to_s
        end
        #print arr.inspect      
        return arr
    end
    
    # when study is deleted, remove any associations with the key questions
    # THIS IS THE SAME AS REMOVE_FROM_JUNCTION ABOVE
    def remove_from_key_question_junction
      entries = StudyKeyQuestion.where(:study_id => self.id)
        unless entries.empty?
            entries.each do |entry|
                entry.destroy
            end
        end 
    end
    
    # when a study is deleted, remove any associations with the extraction forms
    # @deprecated
    # can be deleted?
    def remove_from_extraction_form_junction
        entries = StudyExtractionForm.where(:study_id => self.id)
        entries.each do |entry|
            entry.destroy
        end
    end
    
    # @deprecated
    # can be deleted?
    def self.get_num_extforms(study_id)
        extforms = StudyExtractionForm.where(:study_id => study_id).all
        return extforms.length
    end
    
    # create a number of studies using a list of pubmed ids
    # the only information saved for the study will be the primary publication, and 
    # a list of all studies will show up in the studies index page.
    # @param [Array] pmids an array of pubmed identifiers
    # @param [Array] key_questions an array of key question ids to assign
    # @param [integer] project_id the id of the current project
    # @param [integer] extraction_form_id the id of the extraction_form being used
    # @param [integer] user_id the id of the current user
    # @return [array]
    def self.create_for_pmids(pmids, key_questions, project_id, extraction_form_id, user_id)
        items_not_found = []
        
        pmids.each do |pmid|
            # create a new study and corresponding primary publication
            study = Study.new(:project_id=>project_id, :creator_id=>user_id)
            
            # if the above information can be saved successfully...
            if study.save
                # returns an array as [title, authors, year, affiliation]
                summary = SecondaryPublication.get_summary_info_by_pmid(pmid)
                puts "SUMMARY @ 0 = #{summary[0]}\n\n"
                unless summary[0].start_with?("Not Found", "ERROR") 
                    pub = PrimaryPublication.new(:study_id=>study.id, :title=>summary[0], :author=>summary[1], :country=>summary[2], :year=>summary[3], :pmid=>pmid, :journal=>summary[4], :volume=>summary[5], :issue=>summary[6])
                    # if the primary publication can't be saved then it wouldn't have a title, so destroy
                    # the study and keep record of that id
                    
                    if !pub.save
                        study.destroy
                        items_not_found << pmid
                    else
                        unless key_questions.empty?
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
            end
        end 
        return items_not_found
    end
    
    # assign the key questions and extraction forms to the study AT THE TIME THE STUDY IS CREATED.
    # key questions are attached to extraction forms during the project creation process, so users
    # do not have the option of assigning extraction forms during study creation.
    # @deprecated StudyExtractionForm is deprecated
    # @param [hash] study_params the parameters submitted
    def assign_kqs_and_efs(study_params)
        ef_sections = Hash.new()
        study_params.keys.each do |key|
            kq_id = study_params[key]
            ef_id = ExtractionFormKeyQuestion.where(:key_question_id => kq_id).collect{|record| record.extraction_form_id}[0]
            exists = StudyExtractionForm.where(:study_id=>self.id, :extraction_form_id=>ef_id)
            if exists.empty? && ef_id
                StudyExtractionForm.create(:study_id=>self.id, :extraction_form_id=>ef_id)
            end
            if !ef_sections.keys.include?(ef_id)
                sections = ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=? AND included=?", ef_id, true],:select=>["section_name"])
                sections = sections.empty? ? [] : sections.collect{|x| x.section_name}
                ef_sections[ef_id] = sections.uniq
                
                # set up the complete_study_sections for this form and study combo
                ef_sections[ef_id].each do |sect|
                    CompleteStudySection.create(:study_id=>self.id, :extraction_form_id=>ef_id, :section_name=>sect, :is_complete=>false)
                end
                # also put in the publications and key question setup tabs
                CompleteStudySection.create(:study_id=>self.id, :extraction_form_id=>ef_id, :section_name=>"questions", :is_complete=>false)
                CompleteStudySection.create(:study_id=>self.id, :extraction_form_id=>ef_id, :section_name=>"publications", :is_complete=>false)

            end
            StudyKeyQuestion.create(:study_id=>self.id, :key_question_id=>kq_id, :extraction_form_id=>ef_id) if ef_id
        end
    end

    # return relevant information for the page header in each study editing section.
    # This includes name of the first author, title of the article, journal, year, volume and issue.
    # @param [integer] sid the id of the current study
    # @return [array] an array: [author,title,journal title, volume, issue, year]
    def self.get_page_header_details sid
        pub = PrimaryPublication.where(:study_id=>sid)
        title,year,jtitle,volume,issue,year=["-- Not Found --","-- Not Found --","-- Not Found --","-- Not Found --","-- Not Found --","-- Not Found --"]
        unless pub.empty?
            pp = pub.first
            # get primary author
            author = pp.author
            author = author.nil? ? "" : author.split(",")
            author = author.first

            title = pp.title        # get article title
            jtitle = pp.journal # get journal title
            volume = pp.volume  # get journal volume
            issue = pp.issue        # get journal issue
            year = pp.year          # get journal year
        else
            title = "-- Not Found --"
        end
        return [author,title,year,jtitle,volume,issue,year]
    end
    

    # get the login name of the user who created this study
    # @return [string] the user login
    def get_study_creator
        uid = self.creator_id
        user = User.find(uid)
        return user.login
    end
    

  # provide existing outcome data entries for the study. 
  # @return [hash] a hash indexed by the outcome id and subgroup id to to represent all data entries for the study. the hash will point to an array containing:
  # @return [array] an array of outcome data entry objects that can be used to map comparison data information for the existing_comparisons session variables
  #   [[ocde, [ocde_measures], [ocde_datapoints], [[comparisons], [comparators], [measures], [datapoints]]]]
  def get_existing_results_for_session ef_id=nil
    results_hash = Hash.new()     # the hash to store result data
    #data_entries = Array.new()    # an array of data entries which will be used to reference
                                  # when gathering comparison information
    #ocde_ids = Array.new
    # get all outcomes in the study
    outcomes = []
    if ef_id.nil?
        outcomes = Outcome.find(:all, :conditions=>["study_id=?",self.id], :order=>["outcome_type ASC"])
    else
        outcomes = Outcome.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",self.id, ef_id], :order=>["outcome_type ASC"])
    end
    #outcomes = self.outcomes.order("outcome_type ASC")
    
    # navigate through the outcomes
    unless outcomes.empty?
        outcomes.each do |oc|
          sgs = oc.outcome_subgroups                # get the outcome subgroups, which should always
                                                    # contain at least the default
          # for each subgroup, gather outcome data entries, comparisons, etc. and assign them 
          # to the hash using the outcome and subgroup id
          sgs.each do |sg|
            
            results_array = oc.get_existing_results(sg.id) 
            #data_entries += results_array.pop # the last element are the data entries
            
            hashkey = "#{oc.title}_#{oc.id}_#{sg.title}_#{sg.id}"
            unless results_array.empty?
                results_hash[hashkey] = results_array
            end
          end
        end
    end
    return results_hash
  end # end get_existing_data_entries


  # return all data entry objects associated with a given study
  # @return [array] data entry objects associated with a study
  def get_data_entries
    retVal = Array.new()  

    retVal = OutcomeDataEntry.where(:study_id=>self.id).order("outcome_id ASC","subgroup_id ASC","display_number ASC")
    return retVal

  end
  # get comparison entries
  # obtain a list of comparison entries for a given study.
  # @return [array] retVal  - an array of comparison objects linked to the study
  def get_comparison_entries
    return Comparison.where(:study_id=>self.id).order("outcome_id ASC","subgroup_id ASC, section ASC, group_id ASC")
  end

  # get completed sections
  # get a hash indexed by section name that says whether or not the section of the study has been flagged as 'complete'
  def self.get_completed_sections(study_id, ef_id)
    hits = CompleteStudySection.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id, ef_id], :select=>["is_complete","flagged_by_user","section_name"])
    retVal = Hash.new()
    hits.each do |hit|
        retVal[hit.section_name] = [hit.is_complete, hit.flagged_by_user]
    end
    return retVal
  end

  # toggle_section_complete
  # given a study id, extraction form id and section name toggle the form from complete to incomplete or vice versa
  # @return the new status (true or false)
  def self.toggle_section_complete study_id, extraction_form_id, section, user_id
    complete = true
    if section == 'all'
        puts "\n\nThe section is ALL\n\n"
        entry = CompleteStudySection.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id,extraction_form_id],:select=>["id","is_complete"])
        complete = entry.empty? ? true : entry.first.is_complete == true ? false : true
        entry.each do |e|
            e.is_complete = complete
            e.flagged_by_user = user_id
            e.save
        end
    else
        entry = CompleteStudySection.find(:first, :conditions=>["study_id=? AND extraction_form_id=? AND section_name=?",study_id, extraction_form_id, section], :select=>["id","is_complete","flagged_by_user"])
        complete = false
        if entry.nil?
            CompleteStudySection.create(:study_id=>study_id, :extraction_form_id=>extraction_form_id, :section_name=>section, :is_complete=>true, :flagged_by_user=>user_id)
            complete = true
        else
            current = entry.is_complete
            current = current == true ? false : true
            entry.is_complete = current
            entry.flagged_by_user = user_id
            entry.save
            complete = current
        end
    end
    return complete
  end

  # get notes for study list
  # Return a hash indexed by study_id that points to a string
  def self.get_notes_for_study_list study_ids
    #puts "------ entered get notes for study list -------\nStudy ids are #{study_ids.join(', ')}\n\n"
    retVal = Hash.new()
    study_ids.uniq!
    ef_kqs = Hash.new()
    notes = StudyStatusNote.find(:all, :conditions=>["study_id IN (?)",study_ids],:select=>["study_id","note","user_id","extraction_form_id"])
    #puts "FOund #{notes.length} notes\n\n"
    notes.each do |note|
        #puts "Note is #{note.note}, for study #{note.study_id}\n\n"
        # determine the key questions this note apply to (which extraction form)
        unless ef_kqs.keys.include?(note.extraction_form_id)
            kq_ids = ExtractionFormKeyQuestion.find(:all, :conditions=>["extraction_form_id=?",note.extraction_form_id],:select=>["key_question_id"])
            unless kq_ids.empty?
                qnums = KeyQuestion.find(:all, :conditions=>["id IN (?)",kq_ids.collect{|x| x.key_question_id}.uniq], :select=>["question_number"])
                qnums = qnums.collect{|x| x.question_number}.sort unless qnums.empty?
                ef_kqs[note.extraction_form_id] = qnums.join(", ")
            end
        end

        # build the note string
        if retVal.keys.include?(note.study_id)
            retVal[note.study_id] += "<br/><br/>(KQs #{ef_kqs[note.extraction_form_id]}) #{note.note}"
        else
            retVal[note.study_id] = "(KQs #{ef_kqs[note.extraction_form_id]}) #{note.note}"
        end
    end
    return retVal
  end

  # get_completion_percentages
  # Get the number of completed sections from the extraction form. This is equal to the number of extraction
  # form sections marked as complete divided by the number of extraction form sections in the form. 
  # Sections that need to be marked complete are:
  # Design Details
  # Arms
  # Arm Details
  # Outcomes
  # Outcome Details
  # Baseline Characteristics
  # Results
  # Quality 
  # Adverse Events
  def self.get_completion_percentages study_ids
    retVal = Hash.new()
    unless study_ids.empty?
        
        all_entries = CompleteStudySection.find(:all, :conditions=>["study_id IN (?)",study_ids], :select=>["study_id","extraction_form_id","is_complete"])
        study_efs = StudyExtractionForm.find(:all, :conditions=>["study_id IN (?)",study_ids], :select=>["study_id","extraction_form_id"])
        
        included_section_counts = Hash.new()
        study_efs.collect{|x| x.extraction_form_id}.uniq.each do |efid|
            
            #efs.each do |efid|
            included_section_counts[efid] = ExtractionFormSection.count(:conditions=>["extraction_form_id=? AND included=?",efid,true])
        end
            
        study_ids.each do |sid|
            begin
                these_efs = study_efs.select{|sef| sef.study_id == sid}.collect{|x| x.extraction_form_id}.uniq
            
                # we add 2 to total sections to account for key questions and publications tabs.
                total_sections = 2 * these_efs.length
                these_efs.each do |ef|
                    total_sections += included_section_counts[ef]
                end
                t_entries = all_entries.count{|y| y.is_complete == true && y.study_id == sid && these_efs.include?(y.extraction_form_id)}
                
                unless t_entries == 0 || total_sections == 0
                    #retVal[sid] = (t_entries.length.to_f / these_entries.length) * 100
                    retVal[sid] = (t_entries.to_f / total_sections) * 100
                else
                    retVal[sid] = 0
                end
            rescue Exception => e
                retVal[sid] = 0
            end
        end         
    end
    return retVal
  end

  # extraction_form_ids
  # get extraction form ids assigned to a particular study
  def self.extraction_form_ids(study_id)
    ids = StudyKeyQuestion.find(:all, :conditions=>["study_id=>?",study_id],:select=>[:extraction_form_id])
    return ids.collect{|x| x.extraction_form_id}.uniq
  end

end
