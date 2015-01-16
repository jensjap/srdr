# == Schema Information
#
# Table name: outcomes
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  title              :string(255)
#  is_primary         :boolean
#  units              :string(255)
#  description        :text
#  notes              :text
#  outcome_type       :string(255)
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Outcome < ActiveRecord::Base

    belongs_to :study, :touch=>true
    has_many :comparisons, :dependent=>:destroy
    has_many :outcome_data_entries, :dependent=>:destroy
    has_many :outcome_results, :dependent=>:destroy
    has_many :outcome_timepoints, :dependent=>:destroy
    has_many :outcome_subgroups, :dependent=>:destroy

    scope :sorted_by_created_date, lambda{|efid, study_id| where("extraction_form_id=? AND study_id=?", efid, study_id).
                select(["id","title","description"]).
                order("created_at ASC")}
    #validates_presence_of :outcome_timepoints
    belongs_to :study
    #accepts_nested_attributes_for :outcome_timepoints, :allow_destroy => true
    #accepts_nested_attributes_for :allow_destroy => true, :reject_if => proc { |attributes| attributes['title'].blank? }
    attr_accessible :study_id, :title, :is_primary, :units, :description, :notes, :outcome_timepoints_attributes, :outcome_columns_attributes, :outcome_type, :extraction_form_id
    validates_presence_of :title

    def self.outcome_has_measures(outcome)
        @measures = OutcomeMeasure.where(:outcome_data_entry_id => outcome.id).all
        if @measures.length > 0
            return true
        else
            return false
        end
    end

    # GET THE COLLECTION OF TIMEPOINTS ASSOCIATED WITH AN ARRAY OF OUTCOMES
    # - EACH TIMEPOINTS ARRAY IS INDEXED BY THE OUTCOME ID
    def self.get_timepoints_hash(outcome_array)
        retVal = Hash.new
        unless outcome_array.empty?
            outcome_array.each do |oc|
                timepoints = oc.outcome_timepoints
                unless timepoints.empty?
                    tmp_array = timepoints.collect{|x| [x.id.to_s,x.outcome_id.to_s,x.number.to_s,x.time_unit.to_s]}
                    #timepoints.each do |tp|
                    #   tmp_tp = tp.collect{|x| [x.id.to_s,x.outcome_id.to_s,x.number.to_s,x.time_unit.to_s]}
                    #   tmp_array << tmp_tp
                    #end
                    retVal[oc.id.to_s] = tmp_array
                else
                    retVal[oc.id.to_s] = []
                end
            end 
        end
        return retVal
    end

    def self.at_least_one_has_data(outcome_list)
        outcome_list.each do |one_outcome|
            if Outcome.outcome_has_measures(one_outcome)
                return true
            end
        end
        return false
    end

    # get an array of timepoint arrays for a collection of outcome objects
    def self.get_timepoints_for_outcomes_array(outcomes)
        retVal = [];
        unless outcomes.empty?
            i = 0;
            for oc in outcomes
                  timepoints = get_timepoints_array(oc.id)
                retVal[i] = timepoints
                i += 1
            end
        end
        return retVal
    end

    # get_timepoint_unit_options
    # - returns a list of pre-defined timepoint unit options as well as
    #   a list of units for timepoints already added for this study
    #   An 'Other' field is also included.
    def self.get_timepoint_unit_options(study_id)
        outcomes = Outcome.where(:study_id=>study_id)
        timepoints = Outcome.get_timepoints_for_outcomes_array(outcomes)
        units = ["seconds", "minutes", "hours", "days", "weeks", "months", "years", "baseline"] 
        saved_units = []
        unless timepoints.empty? 
            timepoints.each do |timepoint|
                points = timepoint.collect{|tp| tp.time_unit}       
                saved_units += points   
            end
        end

        #saved_units.uniq!
        #saved_units.sort!
        #units += saved_units
        units.uniq!
        units << 'Other'
        return units
    end

    def self.get_title(id)
        if id.to_i > 0
            @outcome = Outcome.find(id, :select=>[:title])
            return @outcome.title
        else
            return nil
        end
    end

    def self.get_timepoints(outcome_id)
        @outcome_tps = OutcomeTimepoint.where(:outcome_id => outcome_id).all
        tp_array = []
        for i in @outcome_tps
            tp_array << i.number.to_s + " " + i.time_unit
        end
        tp_list = tp_array.join(', ')
        return tp_list 
    end

    # get the timepoints associated with an outcome
    def self.get_timepoints_array(outcome_id)
        outcome_tps = OutcomeTimepoint.where(:outcome_id => outcome_id).all
        retVal = Array.new

        unless outcome_tps.empty?
            # put the baseline timepoint first
            retVal << outcome_tps[outcome_tps.length-1]
            (0..outcome_tps.length-2).each do |i|
                retVal << outcome_tps[i]
            end
        end
        return retVal 
    end
    # get_timepoints_for_outcomes.
    # get timepoints associated with a list of outcomes.
    # return a hash to indicate which timepoints are associated with which
    # outcome
    # @param    outcome_list    a list of outcome ids
    # @return   timepoints      a has containing arrays of timepoints referenced by outcome
    def self.get_timepoints_for_outcomes(outcome_list)
        timepoints = Hash.new
        unless outcome_list.empty?
            outcome_list.each do |oc|
                tp = get_timepoints_array(oc)
                timepoints[oc] = tp
            end
        end 
        return timepoints
    end

    def self.get_array_of_titles(outcome_ids)
        retVal = Array.new()
        outcome_ids.each do |id|
            tmp = Outcome.find(id, :select=>'title')
            retVal << tmp.title
        end
        return retVal
    end

    # get_extraction_form_information
    # gather the following outcome-related information based on a list of extraction forms
    # associated with the study. Also gathers information re: the project
    # RETURN:
    #  - extraction_forms  (an array of extraction form objects)
    #  - outcome_descriptions (hash containing description, data type)
    #  - outcomes (an array of outcomes from the extraction forms and project)
    #  - included_sections (hash stating which sections are included for each form)
    #  - borrowed_section_names (hash stating the names of sections being borrowed in each form)
    #  - section_donor_ids  (hash providing the donor id for any section borrowing data from another)
    # PARAMS: 
    #  - ef_list    : the result of querying StudyExtractionForm for the study id
    #  - study_obj  : rails object representing the study
    #  - proj_obj   : rails object representing the project
    def self.get_extraction_form_information(ef_list, study_obj, project_obj)
        # set up all of the values that we will eventualy return to the controller
        extraction_forms = Array.new
        outcomes = Array.new
        included_sections, borrowed_section_names = [Hash.new, Hash.new]
        section_donor_ids, kqs_per_section = [Hash.new, Hash.new]
        outcome_descriptions = Hash.new

        # for each extraction form associated with the study
        ef_list.each do |record|
            ef_id = record.extraction_form_id

            # add the extraction form to the extraction_forms list
            tmpForm = ExtractionForm.find(ef_id)
            extraction_forms << tmpForm 

            # determine which sections are included, and which ones are included but borrowed
            # and add this information to the appropriate hashes
            included = ExtractionFormSection.get_included_sections(ef_id)
            borrowed = ExtractionFormSection.get_borrowed_sections(ef_id)
            included_sections[ef_id] = included
            unless borrowed.empty?
                borrowed_section_names[ef_id] = borrowed.collect{|x| x[0]}
                section_donor_ids[ef_id] = borrowed.collect{|x| x[1]}
            else
                borrowed_section_names[ef_id] = []
                section_donor_ids[ef_id] = []
            end     

            # determine which key questions are addressed in each extraction form section. The values
            # will display in the side study navigation panel as ex:  Outcome Setup [1,2,3] 
            kqs_per_section[ef_id] = ExtractionFormSection.get_questions_per_section(ef_id,study_obj)

            # get suggested outcomes from the form and add them to the list
            records = ExtractionFormOutcomeName.get_outcomes_array(ef_id)
            outcomes = outcomes + records[0] unless records.empty?

          tmp_desc = records[1]
          if !tmp_desc.nil?
              for key in tmp_desc.keys
                if outcome_descriptions[key].nil? || outcome_descriptions[key].empty?
                    outcome_descriptions[key] = tmp_desc[key]
                end
              end
          end
        end # end ef_list.each
        # add the default value to the descriptions list
        outcome_descriptions["Choose a suggested outcome..."] = [""]

        # pull in previous outcomes for the project and add those to outcomes choices 
        # and descriptions
        previous_outcomes = Project.get_outcomes_array(project_obj.id) 
        previous_names = previous_outcomes[0]
        prev_desc = previous_outcomes[1]
        for key in prev_desc.keys
            if outcome_descriptions[key].nil?
                outcome_descriptions[key] = prev_desc[key]
            end
        end
        outcomes = outcomes + previous_names
        outcomes.uniq!
        outcomes = [["Choose a suggested outcome...","Choose a suggested outcome..."]] + outcomes + [["Other","Other"]]
        return [extraction_forms, outcomes, outcome_descriptions, 
                included_sections, borrowed_section_names, section_donor_ids, kqs_per_section]
    end

    # get_suggestions_for_ef
    # Given an extraction form ID, find all outcomes that have previously been generated.
    # Store the data as a hash referenced by the title which should be unique, and the hash
    # should point to an array containing the description and type for the outcome option
    def self.get_suggested_outcomes_for_ef(efid, current_study_id)
        #outcomes = Outcome.find(:all, :conditions=>["extraction_form_id=? AND study_id != ?",efid,current_study_id])
        outcomes = Outcome.find(:all, :conditions=>["extraction_form_id=?",efid], :order=>"lower(title) ASC")
        unique_outcomes = Hash.new()

        # loop through the outcomes and keep a unique hash of titles, descriptions, units, types
        outcomes.each do |oc|
            unless unique_outcomes.keys.map{|key| key.downcase}.include?(oc.title.downcase)
                #unique_outcomes[oc.title] = {'description'=>oc.description, 'units'=>oc.units, 'type'=>oc.outcome_type}
                unique_outcomes[oc.title] = [oc.description, oc.units, oc.outcome_type]
            end
        end
        return unique_outcomes
    end

    # get_dropdown_options_for_new_outcome
    def self.get_dropdown_options_for_new_outcome ef_id, study_id
        begin
            ###puts "Entered the get_dropdown_options... function with ef_id #{ef_id} and study_id #{study_id}\n\n"
            retVal = Hash.new()
            title_list = Array.new()
            # get the suggested outcome names and descriptions from the extraction form
            ef_outcomes = ExtractionFormOutcomeName.find(:all, :conditions=>["extraction_form_id = ? ", ef_id], :select=>["title","note","outcome_type"], :order=>"lower(title) ASC")
            retVal["--- Extraction Form Suggestions ---"] = ['','',''] unless ef_outcomes.empty? 

            ef_outcomes.each do |efoc|
                title_list << efoc.title.downcase
                # TRYING TO REMOVE SPECIAL CHARACTERS THAT ARE BREAKING THINGS!
                #retVal[efoc.title.scan(/[a-zA-z0-9\s]/).join("")] = [efoc.note.scan(/[a-zA-z0-9\s]/).join(""), "", efoc.outcome_type]
                retVal[efoc.title] = [efoc.note, "", efoc.outcome_type]
            end

            # get all other outcomes that have been added to the project for the same extraction form 
            other_outcomes = Outcome.find(:all, :conditions=>["extraction_form_id = ? AND lower(title) NOT IN (?) AND study_id != ?",ef_id,title_list,study_id], :select=>["title","description","units","outcome_type"], :order=>"lower(title) ASC")
            retVal["--- Created by Data Extractors ---"] = ['','',''] unless other_outcomes.empty?
            other_outcomes.each do |otheroc|
                unless title_list.include?(otheroc.title.downcase)
                    title_list << otheroc.title.downcase
                    retVal[otheroc.title] = [otheroc.description, otheroc.units, otheroc.outcome_type]
                end
            end

            return retVal
        rescue Exception=>e
            puts "encountered an error in get_dropdown_options_for_new_outcome: #{e.message}\n\n#{e.backtrace}\n\n"
        end
    end

    # has_data
    # determine whether or not any data has already been saved for a 
    # particular outcome. If Yes, return TRUE, if no, return FALSE
    # also return a message stating where data has been saved (results
    # or comparisons)
    # return a boolean
    def has_data
        retVal = false
        data_locations = Array.new()

        # if there are outcome data entries defined for the outcome, then return true
        data_entry_ids = OutcomeDataEntry.find(:all, :conditions=>["outcome_id=?",self.id],:select=>["id"])
        #data_entry_ids = data_entry_ids.empty? ? [] : data_entry_ids.collect{|x| x.id}
        
        data_entry_ids.each do |deid|
            unless deid.outcome_data_points.empty?
                retVal = true
                data_locations << "Descriptive Results"
            end
        end
        return retVal, data_locations
    end

    # update_subgroups
    # when an outcome is updated, the user could have added or removed 
    # subgroup definitions. Any submissions with a negative identifier are new
    # and need to be saved. Any with positive IDs should be updated and saved
    def update_subgroups(sg_names, sg_descriptions)
        # get those previously saved so that we know what was deleted
        previous = self.outcome_subgroups
        previous_ids = previous.collect{|x| x.id}

        # the keys in either the names or descriptions hold the object ID
        sg_names.keys.each do |key|
            # if the key is positive
      if key.to_i > 0
              # remove it from the previous array
              if previous_ids.include?(key.to_i)
                previous.delete_at(previous_ids.index(key.to_i))
                previous_ids.delete(key.to_i)
              end
              # update the name and description and save changes
              begin
                sg = OutcomeSubgroup.find(key.to_i)
              rescue
                puts "\n\nERROR: could not find the outcome subgroup with id = #{key}\n\n"
                sg = nil
              end
              unless sg.nil?
                sg.update_attributes(:title => sg_names[key], :description=>sg_descriptions[key]);
              else
                OutcomeSubgroup.create(:outcome_id=>self.id,:title=>sg_names[key],
                                                             :description=>sg_descriptions[key])
              end
            # else if the key is negative
            else
              # create a new outcome subgroup using the name and description provided
              OutcomeSubgroup.create(:outcome_id=>self.id, :title=>sg_names[key], 
                                                         :description=>sg_descriptions[key])
            end
        end
        # remove those still left in the previous array
        previous.each do |p|
            p.destroy();
        end
    end

    # update_timepoints
    # when an outcome is updated, the user could have added or removed 
    # timepoint definitions. Any submissions with a negative identifier are new
    # and need to be saved. Any with positive IDs should be updated and saved
    def update_timepoints(tp_numbers, tp_units)
        # get those previously saved so that we know what was deleted
        previous = self.outcome_timepoints
        previous_ids = previous.collect{|x| x.id}

        # put the timepoint numbers in the proper order
        tp_numbers = tp_numbers.sort{|a,b| b[0].to_i<=>a[0].to_i}
        # the keys in either the names or descriptions hold the object ID
        tp_numbers.each do |tpArray|
            # if the key is positive
            key = tpArray[0]
            num = tpArray[1]
            if key.to_i > 0
              # remove it from the previous array
              if previous_ids.include?(key.to_i)
                previous.delete_at(previous_ids.index(key.to_i))
                previous_ids.delete(key.to_i)
              end
              # update the name and description and save changes
              begin
                tp = OutcomeTimepoint.find(key.to_i)
              rescue
                puts "\n\nERROR: could not find the outcome timepoint with id = #{key}\n\n"
                tp = nil
              end
              unless tp.nil?
                tp.update_attributes(:number => num, :time_unit=>tp_units[key]);
              else
                OutcomeTimepoint.create(:outcome_id=>self.id,:number=>num,
                                                             :time_unit=>tp_units[key])
              end
            # else if the key is negative
            else
              # create a new outcome subgroup using the name and description provided
              OutcomeTimepoint.create(:outcome_id=>self.id,:number=>num,
                                                             :time_unit=>tp_units[key])
            end
        end
        # remove those still left in the previous array
        previous.each do |p|
            p.destroy();
        end
    end

    # get_subgroups_by_outcome
    # given an array of outcome ids, return a hash referenced by id that contains
    # arrays of outcome subgroups.
    def self.get_subgroups_by_outcome outcomes
        retVal = Hash.new
        outcomes.each do |oc|
            sgs = oc.outcome_subgroups
            if sgs.empty?
                newOCSG = OutcomeSubgroup.create(:outcome_id=>oc.id, :title=>"All Participants", :description=>"All Participants")
                retVal[oc.id] = Array.new
                retVal[oc.id] << newOCSG
            else
                retVal[oc.id] = sgs
            end
        end
        return retVal
    end

    # get_foot_notes
    # for a given outcome, return a collection of footnotes sorted by their footnote display number
    # @return  footnotes - a sorted collection of footnotes from outcome_data_entries and comparisons
    def get_foot_notes subgroup_id
        ##puts "ENTERING THE GET_FOOT_NOTES FUNCTION\n"
        footnotes = []
        # get all outcome data entries
        outcome_data_entries = OutcomeDataEntry.where(:outcome_id=>self.id, :subgroup_id=>subgroup_id, :study_id=>self.study_id,                                                                                                        :extraction_form_id=>self.extraction_form_id)
        # for each data entry that we find...
        outcome_data_entries.each do |ocde|
            ##puts "----------------------\nWorking on ocde with id of #{ocde.id}...\n\n"
            # get all the measures associated with the data entry
            oc_measures = ocde.outcome_measures
            oc_measures = oc_measures.collect{|x| x.id}

            # get the datapoints associated with the measure
            oc_dps = OutcomeDataPoint.find(:all,:conditions=>["outcome_measure_id IN (?) AND footnote_number > ? AND footnote <> ?",oc_measures,0,""], :select=>["id","footnote","footnote_number"])    

            ##puts "Found #{oc_dps.length} datapoints for this measure.\n"
            oc_dps.each do |dp|
                ##puts "Starting on datapoint #{dp.id} and entering a footnote of #{dp.footnote}\n\n"
              footnotes[dp.footnote_number-1] = dp
            end
        end 

        # get all comparisons for the outcome
        comparisons = Comparison.where(:outcome_id=>self.id, :subgroup_id=>subgroup_id, :study_id=>self.study_id,
                                                               :extraction_form_id=>self.extraction_form_id)
        # go through each comparison and pull out comparison measures 
        comparisons.each do |comp|
            comp_measures = comp.comparison_measures
            comp_measures = comp_measures.collect{|x| x.id}
            # for each comparison measure in the comparison, find datapoints with footnotes
            comp_dps = ComparisonDataPoint.find(:all,:conditions=>["comparison_measure_id IN (?) AND footnote_number > ? 
                                                            AND footnote <> ?",comp_measures,0,""],:select=>["id","footnote","footnote_number"])
            # for each datapoint found that has footnotes, add them to the array based on the footnote number
            comp_dps.each do |cmp_dp|
                footnotes[cmp_dp.footnote_number-1] = cmp_dp
            end
        end
        return footnotes
    end

    # get_existing_results
    # gather existing outcome result data for this outcome. Put it into an array format such as:
    # [[ocde, [ocde_measures], [ocde_datapoints]]]
    # @return retVal  - the array described above
    # @return objs     - an array of outcome data entry objects that will be used to find 
    #                   corresponding comparison data. THIS IS INCLUDED AT THE END OF THE retVal ARRAY
    def get_existing_results subgroup_id
        retVal = Array.new()
        # gather the outcome data entries for this outcome/subgroup pair
        results = OutcomeDataEntry.where(:outcome_id=>self.id, :subgroup_id=>subgroup_id).order("display_number ASC")
        unless results.empty?
          results.each do |res|
            result_entry = Array.new()
            result_entry << res  # store the result entry itself

            # obtain the measures associated with the data entry
            measures = res.outcome_measures
            unless measures.empty?
                result_entry << measures
                # obtain the data points associated with the measure
                dp_hash = Hash.new    # a hash to store data points per measure
                measures.each do |m|
                    dp_hash[m.id] = Hash.new
                    datapoints = OutcomeDataPoint.where(:outcome_measure_id=>m.id)
                    unless datapoints.empty?
                        datapoints.each do |dp|
                            dp_hash[m.id][dp.arm_id] = dp
                        end
                    end
                end
                result_entry << dp_hash
            else
                result_entry << []   # empty measures
                result_entry << {}   # empty data points
            end
            retVal << result_entry
          end
        end
        return retVal
    end

    # get_timepoints_by_outcome_data_entry
    # for all outcome data entries associated with the outcome and
    # [[ocde, [ocde_measures], [ocde_datapoints]]]
    # @params ocid    - the ID of the outcome
    # @params sgid    - the ID of the subgroup
    # @return retVal  - the array of timepoint ids
    def self.get_timepoint_ids_by_outcome_data_entry(ocid, sgid)
        retVal = Array.new()
        # gather the outcome data entries for this outcome/subgroup pair
        results = OutcomeDataEntry.where(:outcome_id=>ocid, :subgroup_id=>sgid).order("display_number ASC")
        unless results.empty?
          results = results.collect{|x| x.timepoint_id}
          #results.each do |res|
            # get the timepoint ID and add it to retVal
            #tpID = res.timepoint_id
            #retVal << tpID
            #end
            retVal = results
        end
        # return the array
        return retVal
    end

    # get_timepoints_by_outcome_data_entry
    # for all outcome data entries associated with the outcome and
    # [[ocde, [ocde_measures], [ocde_datapoints]]]
    # @params ocid    - the ID of the outcome
    # @params sgid    - the ID of the subgroup
    # @return retVal  - the array of timepoint ids
    def self.get_timepoint_ids_by_comparison(ocid, sgid, section)
        retVal = Array.new()
        # gather the outcome data entries for this outcome/subgroup pair
        results = Comparison.where(:outcome_id=>ocid, :subgroup_id=>sgid, :section=>section)
        unless results.empty?
            results = results.collect{|x| x.group_id}
            retVal = results
        end
        # return the array
        return retVal
    end
end
