# == Schema Information
#
# Table name: outcome_data_entries
#
#  id                 :integer          not null, primary key
#  outcome_id         :integer
#  extraction_form_id :integer
#  timepoint_id       :integer
#  study_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  display_number     :integer          default(1)
#  subgroup_id        :integer          default(0)
#

class OutcomeDataEntry < ActiveRecord::Base
    belongs_to :study, :touch=>true
    has_many :outcome_measures, :dependent=>:destroy
    has_many :outcome_data_points, :through => :outcome_measures

    # remove any outcome data associated with an outcome data entry. this function
    # is necessary because some data points may have footnotes that need to be
    # re-ordered when they're deleted.
    def remove_outcome_data
        datapoints = self.outcome_data_points
        unless datapoints.empty?
            datapoints.each do |dp|
                if dp.footnote_number > 0
                    # get a new copy in case this function updated it already
                    dp_obj = OutcomeDataPoint.find(dp.id) # get a new copy in case this function updated it
                    OutcomeDataEntry.update_footnote_numbers_on_delete(dp_obj.footnote_number,self.outcome_id,self.subgroup_id)
                end
                OutcomeDataPoint.destroy(dp.id)
            end
        end
    end
    # remove any comparison data associated with an outcome data entry. the comparison
    # data will be linked to the entry via the timepoint id, study id, ef id, outcome id
    def remove_comparison_data
        study_id = self.study_id
        ef_id = self.extraction_form_id
        outcome_id = self.outcome_id
        subgroup_id = self.subgroup_id
        group_id = self.timepoint_id
        #-----------------------------
        # between arm comparisons
        comparisons = Comparison.where(:within_or_between=>'between',:study_id=>study_id, 
                                       :extraction_form_id=>ef_id, :outcome_id=>outcome_id,
                                                                     :group_id=>group_id)
    # remove all comparison data for the this OCDE ID                                                                    
        unless comparisons.empty?
            comparisons.each do |c|

                dps = c.comparison_data_points
                unless dps.empty?
                    dps.each do |dp|
                        dp_obj = ComparisonDataPoint.find(dp.id)  # get a new copy in case they update each other 
                        if dp_obj.footnote_number > 0
                            OutcomeDataEntry.update_footnote_numbers_on_delete(dp_obj.footnote_number, outcome_id, subgroup_id)
                            dp_obj.destroy
                        end 
                    end
                end
                c.destroy   # because they're related, this will also remove data points and measures
            end
        end
        #-----------------------------
        # within-arm comparisons
        #print "CHECKING WITHIN_ARM COMPARISONS---------------\n\n"
        comparisons = Comparison.where(:within_or_between=>'within',:study_id=>study_id, 
                                       :extraction_form_id=>ef_id, :outcome_id=>outcome_id)
        unless comparisons.empty?
          puts "DELETING WITHIN ARM COMPARISONS"
          # if the timepoint is included in the within-arm comparison, then destroy
          # that comparison
          comparisons.each do |c|
              #print "looking at comparison #{c.id}\n\n"
            comparators = c.comparators
            unless comparators.empty?
              comparators = comparators.first.comparator.split("_")   
            end
            #print "comparators is #{comparators} and timepoint_id is {#{self.timepoint_id}\n\n"
            if comparators.include?(self.timepoint_id.to_s)
              dps = c.comparison_data_points
              unless dps.empty?
                  dps.each do |dp|
                      if dp.footnote_number > 0
                          OutcomeDataEntry.update_footnote_numbers_on_delete(dp.footnote_number, outcome_id, subgroup_id)
                          dp.destroy
                      end 
                  end
              end
            end
            puts "DESTROYING #{c.id}"
            c.destroy
          end
        end
    end




    # in the event that the user had to create their own measures rather than use the defaults,
    # get the measures
    def get_user_defined_measures
        measures = OutcomeMeasure.find(:all,:conditions=>["outcome_data_entry_id = ? AND measure_type = ?",self.id,0])
        return measures
    end

    # get an array of measures that are unique for the study based on their title
    def get_all_user_defined_measures
        # get all the ocde ids for the study
        study = Study.find(:first, :conditions=>["id=?",self.study_id],:select=>["project_id"])
        project_study_ids = Study.find(:all, :conditions=>["project_id=?",study.project_id],:select=>["id"])
        ocdes = OutcomeDataEntry.find(:all, :conditions=>["study_id IN (?)",project_study_ids], :select=>["id"])
        # get all associated user-defined measures
        measures = OutcomeMeasure.find(:all, :conditions=>["outcome_data_entry_id IN (?) AND measure_type = ?",ocdes,0])
        uniq_measures = []
        title_array = []
        measures.each_with_index do |m,i|
            if !title_array.include?(m.title)
                uniq_measures << m
                title_array << m.title
            end
        end
        return uniq_measures
    end
    # gather a list of all measures used for the data entry. If none have yet been defined, create
    # the defaults
    # the ocde_array is used when trying to get measures for newly created objects. 
    def get_measures(type, new_ocde_ids=[])
        # see if there are any already existing
        ocde_id = self.id
        subgroup_id = self.subgroup_id
        #measures = OutcomeMeasure.find(:all,:conditions=>["outcome_data_entry_id = ? AND measure_type <> ?",ocde_id,0])
        measures = OutcomeMeasure.where(:outcome_data_entry_id => ocde_id)
        print "\n\nJust entered the get_measures function and there are #{measures.length} measures for ocde #{ocde_id}\n"
        # if not, see if others exist and use those
        if measures.empty?
            use_defaults = true
            done_searching = false

            outcome_ids_for_search = Outcome.find(:all, :conditions=>["study_id=? AND extraction_form_id=? AND outcome_type=?",self.study_id,self.extraction_form_id,type],:select=>["id"]).collect{|x| x.id}
            # find the most recently created outcome entries
            existing_entries = OutcomeDataEntry.find(:all, :conditions=>["study_id=? AND extraction_form_id=? AND outcome_id IN (?)",self.study_id,self.extraction_form_id,outcome_ids_for_search],:select=>["id"],:order=>"updated_at DESC")
            # IF IT'S PROJECT 370 WE ALWAYS WANT NEW MEASURES
            unless existing_entries.empty? || self.project_id.to_i == 427 || self.project_id.to_i == 553
                #puts "\nCouldn't find existing measures. Beginning to search...\n"
                while !done_searching
                    # flip through the entries to determine if they have measures assigned to them
                    existing_entries.each do |entry|
                        #puts "\nStarting on entry #{entry.id}...\n"
                        unless new_ocde_ids.include?(entry.id)
                            #print "continuing looking at existing entry #{entry.id}\n"
                            existing_measures = OutcomeMeasure.find(:all, :conditions=>["outcome_data_entry_id=?",entry.id],:select=>["title","description","unit","measure_type"])

                            unless existing_measures.empty?
                                # if there are measures, copy them into new measure objects and stop searching
                                existing_measures.each do |m|
                                    #puts "copying measure #{m.id} from existing entry #{entry.id} into entry #{ocde_id}...\n"
                                    tmpMeasure = OutcomeMeasure.create(:outcome_data_entry_id=>ocde_id, :title=>m.title, 
                                                                                                         :description=>m.description, :unit=>m.unit, 
                                                                                                         :measure_type=>m.measure_type)
                                measures << tmpMeasure
                                #print "added the measure: #{tmpMeasure.title}\n"
                                end
                                done_searching=true
                                use_defaults = false
                                #print "done searching. \n\n"
                                break;
                            else
                                #puts "found nothing in entry #{entry.id}\n\n"
                            end
                        else
                            #puts "This is one of the ones being created.\n\n\n"
                        end
                    end
                    # otherwise just incidate that we have found the search and need to use defaults
                    done_searching = true
                end
            end
            # if no others exist, use defaults
            if use_defaults || self.project_id.to_i == 427 || self.project_id.to_id == 553
                # account for the switch in nomenclature
                type = type=="Time to Event" ? "survival" : type
                
                if self.project_id == 427 || self.project_id == 553
                    default_measures = DefaultCevgMeasure.find(:all, :conditions=>["outcome_type=? AND results_type=?",type.downcase,0],:select=>["title","description","unit","measure_type"])
                else
                    default_measures = DefaultOutcomeMeasure.find(:all,:conditions=>["outcome_type=? AND is_default=?",type.downcase,true],:select=>["title","description","unit","measure_type"])
                end
                #print "found #{default_measures.length} defaults\n"
                default_measures.each do |m|
                    tmp = OutcomeMeasure.create(:outcome_data_entry_id=>self.id, :title=>m.title, :description=>m.description, :unit=>m.unit, :measure_type=>m.measure_type)
                    #print "added the measure: #{tmp.title}\n"
                    measures << tmp
                end
            end
        end
        #print "the outcome measures array contains #{measures.length} measures."
        return measures
    end

    def project_id
        ef = ExtractionForm.find(self.extraction_form_id)
        return ef.project_id
    end
    # given an array of data entry objects, gather up the measures for each
    # and create a hash with the data entry object ID as the key
    def self.get_measures_for_ocde_array ocde_array, type
        retVal = Hash.new()
        unless ocde_array.empty?
            ocde_array.each do |entry|
                measures = entry.get_measures(type, ocde_array.collect{|x| x.id})
                retVal[entry.id] = measures
            end
        end
        return retVal
    end


    # gather a list of all datapoints saved for this data entry
    # create a hash with keys = outcomeID_timepointID_armID_measureID
    def get_datapoints_hash
        dps = self.outcome_data_points.select(["arm_id","outcome_measure_id","value","is_calculated","footnote_number"])
        retVal = Hash.new
        unless dps.empty?
            dps.each do |dp|
                arm_id = dp.arm_id
                measure_id = dp.outcome_measure_id
                key = "#{self.outcome_id}_#{self.timepoint_id}_#{arm_id}_#{measure_id}"
                retVal[key] = [dp.value,dp.is_calculated,dp.footnote_number]
            end
        end
        return retVal
    end

    # get_datapoints_for_ocde_array
    def self.get_datapoints_for_ocde_array ocde_array
        retVal = Hash.new()
        unless ocde_array.empty?
            ocde_array.each do |entry|
                retVal[entry.id] = entry.get_datapoints_hash
            end
        end
        return retVal
    end

    # allow users to assign footnotes and whether or not the data point value was calculated
    # @param [Int] dp_id     the datapoint id to update
    # @param [String] dp_type   the type of datapoint (outcome or comparison)
    # @param [Boolean] is_calc   is it calculated, "true" or "false"
    # @param [String] footnote  the footnote text to be assigned / updated in this datapoint
    # @param [Int] oc_id     the outcome ID that this data point belongs to
    # @return dp - the updated datapoint object
    def self.assign_data_point_attributes(dp_id, dp_type, is_calc, fnote_text, oc_id, sg_id=0)
    fnote_text.strip!
        footnote_removed = nil     # this is used in case a footnote is blanked out, in which case
                                         # we want to be able to update footnote numbers and apply changes
                                         # visually to the table
    is_calculated = (is_calc == "1") ? true : false         # convert is_calc to boolean
        dp = nil                                          # create a datapoint placeholder

        # if it's an outcome data point..
        if dp_type == 'outcome'
            dp = OutcomeDataPoint.find(dp_id)
        # otherwise if it's a comparison datapoint...
        elsif dp_type == 'comparison'   
            dp = ComparisonDataPoint.find(dp_id)
        end

        # if the footnote is empty
        if fnote_text.empty?
            # if the previous value was not empty
            if !dp.footnote.nil?
                # decrement footnote numbers above this one
                footnote_removed = dp.footnote_number
                OutcomeDataEntry.update_footnote_numbers_on_delete(dp.footnote_number, oc_id, sg_id)
            end

            # set the footnote items to nil and save it
            dp.footnote = nil
            dp.is_calculated = is_calculated
            dp.footnote_number = 0
            dp.save

        # otherwise if the footnote is not empty
      else
        # if the datapoint already has a footnote number, just adjust the footnote and save
        if dp.footnote_number > 0
            dp.footnote = fnote_text
            dp.is_calculated = is_calculated
            dp.save
        else
            # otherwise, determine what number the footnote should have
              # before updating the footnote text and saving
                footnote_num = OutcomeDataEntry.get_next_footnote_number(oc_id)
                dp.footnote = fnote_text
                dp.is_calculated = is_calculated
                dp.footnote_number = footnote_num
                dp.save
            end
        end
        return [dp, footnote_removed]
    end

    # given an outcome id, search all datapoints (outcome and comparison) to find out what the next footnote number 
    # should be
    # @param [Int] outcome_id     the id of the outcome being searched
    # @return        retVal - the next footnote number to set
    def self.get_next_footnote_number outcome_id
        outcome = Outcome.find(outcome_id)
        # get all outcome data entries
        outcome_data_entries = OutcomeDataEntry.where(:outcome_id=>outcome.id, :study_id=>outcome.study_id,
                                                                                                  :extraction_form_id=>outcome.extraction_form_id)
        all_dps = []
        # go through the entries and find all datapoints with a footnote
        outcome_data_entries.each do |ocde|
            all_dps += ocde.outcome_data_points.find(:all,:select=>[:footnote_number],
                                                                                             :conditions=>["footnote_number > ? AND footnote <> ?",0,""])
        end 

        # get all comparisons for the outcome
        comparisons = Comparison.where(:outcome_id=>outcome.id, :study_id=>outcome.study_id,
                                                               :extraction_form_id=>outcome.extraction_form_id)
        # go through each comparison and pull out datapoints with a footnote                                                       
        comparisons.each do |comp|
            all_dps += comp.comparison_data_points.find(:all, :select=>[:footnote_number],
                                                                                                    :conditions=>["footnote_number > ? AND footnote <> ?",0,""])
        end

        # get the max number for all datapoints
        max_num = all_dps.collect{|x| x.footnote_number}.max
        max_num = max_num.nil? ? 0 : max_num

        return max_num + 1

    end

    # when a footnote gets deleted, make sure that other footnote numbers
    # are updated accordingly.
    # @param [Integer] number_being_deleted    - the number of the footnote that's being phased out
    # @param [Integer] outcome_id        - the outcome that these footnotes are being udpated for
    def self.update_footnote_numbers_on_delete(number_being_deleted, outcome_id, subgroup_id)
        begin
            # get the associated outcome
            oc = Outcome.find(outcome_id)

            # get the list of sorted footnotes
            footnotes = oc.get_foot_notes(subgroup_id)

            # for each datapoint in a position in the array above the one being removed,
            # decrement the footnote number and save
            for i in number_being_deleted-1..footnotes.length-1
                tmpDP = footnotes[i]
                tmpDP.footnote_number = tmpDP.footnote_number - 1;
                tmpDP.save
            end
        rescue
            puts "Could not find an outcome with the id of #{outcome_id}"
        end
    end

    # when a user manually specifies a new position for a footnote, adjust all other
    # footnotes to be in the appropriate position.
    # @param [Int] orig_pos    the footnote number before it was changed
    # @param [Int] new_pos     the newly desired footnote number
    # @param [Outcome] outcome     the outcome object that these footnotes belong to
    def self.update_footnote_numbers(orig_pos,new_pos,outcome,subgroup_id)
      # get the collection of footnotes
      dps = outcome.get_foot_notes(subgroup_id)

      # determine which ones need to be updated, and update accordingly
      if new_pos < orig_pos
        for i in new_pos..(orig_pos-1)
            tmpDP = dps[i-1]
            tmpDP.footnote_number = tmpDP.footnote_number + 1
            tmpDP.save
        end
      elsif new_pos > orig_pos
        for i in (orig_pos+1)..new_pos
            tmpDP = dps[i-1]
            tmpDP.footnote_number = tmpDP.footnote_number - 1
            tmpDP.save
        end
      end

      # now update the one that was switched
      tmpDP = dps[orig_pos-1]
      tmpDP.footnote_number = new_pos

      tmpDP.save
    end

    # gather an array of timepoints for this entry table
    # if the user selected 'All' then gather all timepoints for the outcome and return them
    # THIS IS NO LONGER BEING USED SINCE WE'RE USING CHECKBOXES INSTEAD OF SELECTING ALL
    # @deprecated
=begin
    def self.get_timepoints_array(tpid, outcome)
        retVal = Array.new
        if tpid.to_s == "0"
            retVal = outcome.outcome_timepoints
        else
            retVal << OutcomeTimepoint.find(tpid)
        end
        return retVal
    end
=end


    # given an outcome, determine which timepoints should be displayed in the the results table. If no data entry
    # elements were created yet, then all timepoints should be used. Otherwise, give only the timepoints that 
    # have data entry elements
    # @return [string] a string representing the timepoint ids. e.g., 3_5 means timepoints with IDs 3 and 5 should be displayed
    def self.get_selected_timepoints(outcome,subgroup)
        all_tps = outcome.outcome_timepoints.collect{|x| x.id}
        retVal = ""
        data_entries = OutcomeDataEntry.find(:all, :conditions=>["outcome_id=? AND subgroup_id=? AND study_id=? AND extraction_form_id=?",outcome.id,subgroup.id,outcome.study_id,outcome.extraction_form_id],:select=>["timepoint_id"]).collect{|x| x.timepoint_id}
        unless data_entries.empty?
            retVal = data_entries.join("_")
        else
            retVal = all_tps.join("_")
        end
        return retVal
    end

    # get_ocde_objects
    # get an array of outcome data entry objects to display in the entry table
    # @param [Array] timepoints   an array of timepoints for the given outcome
    # @param [Int] ocid         the outcome id
    # @param [Int] sid          the study id
    # @param [Int] efid         the extraction form id
    # @param [Int] sgid         the subgroup id
    # @return [Array] retVal      an array containing outcome data entries in order of display number
    # @return [Array] sorted_timepoints  an array of timepoints sorted according to the position in retVal
    def self.get_ocde_objects(timepoints,ocid,sid,efid,sgid=0)
        #print "\n\n\nGETTING OCDEs and the timepoints are #{timepoints}\n\n\n"
        retVal = []
        sorted_timepoints = []
        do_sorting = true
        # there should be one ocde per timepoint that was selected
        unless timepoints.empty?
            needs_comparisons = true
            timepoints.each do |tp|
              puts "Starting at timepoint #{tp.id}\n\n"
              tmp = OutcomeDataEntry.find(:first, :conditions=>["outcome_id=? AND extraction_form_id=? AND timepoint_id=? AND study_id=? AND subgroup_id=?",ocid,efid,tp.id,sid,sgid],:select=>["id","display_number","timepoint_id","subgroup_id","outcome_id","extraction_form_id","study_id"])

              if tmp.nil?
                puts "I'll have to create a new OCDE\n\n"
                ef = ExtractionForm.find(efid)
                project_id = ef.project_id
                displayNum = OutcomeDataEntry.find(:last, :conditions=>["outcome_id=? AND extraction_form_id=? AND study_id=? AND subgroup_id=?",ocid,efid,sid,sgid],:select=>["display_number"],:order=>["display_number ASC"])                                                                    
                displayNum = displayNum.nil? ? 1 : (displayNum.display_number.nil? ? 1 : displayNum.display_number + 1)
                tmp = OutcomeDataEntry.create(:outcome_id=>ocid, :extraction_form_id=>efid, :timepoint_id=>tp.id, 
                                              :study_id=>sid, :display_number => displayNum,:subgroup_id=>sgid)
                # IF IT'S THE CEVG PROJECT, LET'S ALSO CREATE THE COMPARISONS SECTIONS FOR THEM
                if (project_id.to_i == 427 || project_id.to_id == 553) && needs_comparisons
                    outcome = Outcome.find(ocid)
                    study = Study.find(sid)
                    arms = study.arms.collect{|x| x.id}
                    if arms.length > 1
                        btwn = OutcomeDataEntry.create_comparisons("between",timepoints.collect{|t| t.id},ocid,sgid)
                    end
                    if timepoints.length > 1 && outcome.outcome_type != 'survival'
                        within = OutcomeDataEntry.create_comparisons("within",[1],ocid,sgid)
                    end
                    
                end
              end
              puts "I didn't have to create a new one, but the display number is #{tmp.display_number}\n\n"
              if tmp.display_number.nil? || tmp.display_number == "" || tmp.display_number == 0
                puts "Setting do_sorting to false\n\n"
                do_sorting = false
              end
              # doing this will result in a sorted array by display number
              if do_sorting == true
                puts "adding to sorted retVal"
                  retVal[tmp.display_number - 1] = tmp
                  sorted_timepoints[tmp.display_number - 1] = tp
                else
                    puts "adding to normal retVal"
                    retVal << tmp
                    sorted_timepoints << tp
                end
            end
        end
        # now return the ocdes and timepoints ordered by the display number of the ocde
        return [retVal, sorted_timepoints]
    end


    # given a list of measures saved and those saved previously, update the measures for a given 
    # data entry object.
    def self.update_measures(measures,ocde_id,previous,measure_type='default')
        # keep track of previously saved information so we know what to delete
        previous = previous.split("_")

        unless !defined?(measures)  || measures.nil?|| measures.empty?
            # keys include the default measure id and study measure id separated by a '_'
            measures.keys.each do |key|
                keyParts = key.split("_")
                new_id = keyParts[0]
                prev_id = keyParts[1]

                if prev_id == "0"
                    unless measure_type=='user-defined'
                        measure = DefaultOutcomeMeasure.find(new_id)
                    else
                        measure = OutcomeMeasure.find(new_id)
                    end
                    OutcomeMeasure.create(:outcome_data_entry_id=>ocde_id, :title=>measure.title, :description=>measure.description, :unit=>measure.unit, :measure_type=>measure.measure_type)
                else
                  unless previous.empty?
                    previous.delete_at(previous.index(prev_id))
                  end
                end 
            end
        end
        # Now remove any previous ones that weren't chosen this time.
        # Calling destroy will also remove associated data points due to the model assignments
        unless previous.empty?
            previous.each do |prev|
              p = OutcomeMeasure.find(prev)
              p.destroy 
            end
        end
    end


    # using a list of title and descriptions for new measures, create them for the given ocde
    def self.create_new_measures(titles,descriptions,ocde_ids)
        titles.keys.each do |key|
            title = titles[key]
            description = descriptions[key]
            type = 0
            ocde_ids.each do |ocde_id|
                OutcomeMeasure.create(:outcome_data_entry_id=>ocde_id, :title=>title, 
                                                          :description=>description, :measure_type=>type)
            end
        end
    end


    # given a list of measures saved, update the measures for all entry objects for this outcome/study/extraction form 
    def self.update_measures_for_all(measures, ocid, efid, sid, subgroup, measure_type='default')
        # Get the subgroup ID
        subgroup_id = 0
        unless subgroup.nil?
            subgroup_id = subgroup.id
        end
        # Get the outcome data entries associated with this outcome/subgroup
        entries = OutcomeDataEntry.where(:outcome_id=>ocid, :extraction_form_id=>efid, :study_id=>sid,:subgroup_id=>subgroup_id)
        # if there are measures to be updated
        unless !defined?(measures)  || measures.nil?|| measures.empty?
            # for each of the entries in this subgroup
            entries.each do |entry|

                # WHY IS THIS UNLESS STATEMENT NEEDED IF THEY'RE DOING THE SAME THING? 
                # TRY TESTING REMOVAL OF THIS AT SOME POINT             
                unless measure_type == 'user-defined'
                    # get the measures for that entry
                    previous = OutcomeMeasure.find(:all, :conditions=>["outcome_data_entry_id = ? AND measure_type <> ?",entry.id, 0])
                else
                    # get the user-defined measures
                    previous = OutcomeMeasure.find(:all, :conditions=>["outcome_data_entry_id = ? AND measure_type = ?",entry.id, 0])
                end
                # gather up the previously saved measure titles
                previous_titles = previous.collect{|x| x.title}
                measures.keys.each do |key|
                    # get the id of the measure to be assigned to another 
                    meas_id = key.split("_")[0]
                    unless measure_type == 'user-defined'
                        measure = DefaultOutcomeMeasure.find(meas_id)
                    else
                        measure = OutcomeMeasure.find(meas_id)
                    end
                    # if the measure previously saved is still being used, remove it from the
                    # previous list so that it won't get deleted later
                    if previous_titles.include?(measure.title)
                        previous.delete_at(previous_titles.index(measure.title))
                        previous_titles.delete_at(previous_titles.index(measure.title))
                    else
                    # if the measure is not previously saved in this data entry, then create
                    # it
                        OutcomeMeasure.create(:outcome_data_entry_id=>entry.id, :title=>measure.title, :description=>measure.description, :unit=>measure.unit, :measure_type=>measure.measure_type)
                    end
                end 
                # remove all measures that were previously saved in the entry but are no longer
                # being used
                unless previous.empty?
                    previous.each do |p|
                        p.destroy();
                    end
                end
            end
        else
      # if there are no user-defined measures, make sure we delete them for this study/outcome/extraction form          
            if measure_type == 'user-defined'
                entry_ids = entries.collect{|x| x.id}
                previous = OutcomeMeasure.find(:all, :conditions=>["outcome_data_entry_id in (?) AND measure_type = ?",entry_ids, 0])
                previous.each do |p|
                    p.destroy()
                end
            end
        end
    end


    #-------------------------------------------------------------
  # ALL CODE BELOW THIS POINT IS RELATED TO COMPARISONS
  #-------------------------------------------------------------        


    # get existing comparisons for the current extraction form/study/outcome/timepoints combination.
    # if no comparison exists for one of these points then create a new one.
    # (groups will be timepoints for between-arm, or arms for within-arm)
    def self.get_comparisons(type,groups,ocid,sid,efid,sgid=0)
        retVal = Hash.new()
        # keep record of which groups did not have any comparisons when entering 
        # this function, and which ones did 
        no_comp = Array.new()
        has_comp = Array.new()
        groups.each do |group|
            comp = Comparison.find(:first,:conditions=>["outcome_id=? AND group_id=? AND within_or_between=? AND study_id=? AND extraction_form_id=? AND subgroup_id=?",ocid,group.id,type,sid,efid,sgid])

            if comp.nil?
                no_comp << group.id
            else
                has_comp << group.id
                retVal[group.id] = comp
            end
        end

        # if one group for the table had a comparison then create the rest too...
        if has_comp.length > 0
            no_comp.each do |nc_id|
                comp = Comparison.create(:outcome_id=>ocid, :group_id=>nc_id,
                                                                 :within_or_between=>type, :study_id=>sid,
                                                                 :extraction_form_id=>efid,:subgroup_id=>sgid)
                comp.assign_measures
                retVal[nc_id] = comp
            end
        end
        return retVal
    end

    # get existing diagnostic test comparisons for the current extraction form/study/outcome/timepoints combination.
    # if no comparison exists for one of these points then create a new one.
    # (groups will be timepoints for between-arm, or arms for within-arm)
    # sections describe the three sections found in the diagnostic test results page
    def self.get_diagnostic_comparisons(type,selected_timepoints,all_timepoints,ocid,sid,efid,sgid=0)
        puts "TYPE: #{type}, SELECTEDTIMEPOINTS: #{selected_timepoints}, all_tps:#{all_timepoints},ocid:#{ocid},sid:#{sid},efid:#{efid},sgid:#{sgid}"
        retVal = {1=>{}, 2=>{}, 3=>{}}
        all_selected = []
        selected_timepoints.values.each{|val| all_selected += val}
        all_selected.uniq!

        # keep record of which groups did not have any comparisons when entering 
        # this function, and which ones did 
        section1_no_comp = Array.new()
        section2_no_comp = Array.new()
        section3_no_comp = Array.new()
        section1_has_comp = Array.new()
        section2_has_comp = Array.new()
        section3_has_comp = Array.new()
        puts "OutcomeDataEntry -> get_diagnostic_comparisons...\n\n"
        [1,2,3].each do |section|
            #puts "BEGINNING SECTION #{section}:\n"

            all_timepoints.each do |tp_id|
                puts "CHECKING FOR TIMEPOINT ID #{tp_id}"
                if selected_timepoints[section].include?(tp_id.to_s)
                    puts "FOUND THAT IT WAS INCLUDED..."
                    comp = Comparison.where(:outcome_id=>ocid, :group_id=>tp_id, 
                                :within_or_between=>type, :study_id=>sid,
                                :extraction_form_id=>efid,:subgroup_id=>sgid,:section=>section).first   

                    unless comp.nil?
                        puts "The comparison was not nil, so adding id of #{tp_id} to section#{section}_has_comp\n"
                        begin
                            retVal[section][tp_id] = comp
                            puts "retval for sectoin #{section} and tpid #{tp_id} should now be #{comp}\n"
                        rescue Exception=>e
                            puts 'Found a problem: ' + e.message()
                        end
                        eval("section#{section}_has_comp") << tp_id

                    else
                        puts "COULDN'T FIND THE COMPARISON, CREATING IT"
                        comp = Comparison.create(:outcome_id=>ocid, :group_id=>tp_id, 
                                :within_or_between=>type, :study_id=>sid,
                                :extraction_form_id=>efid,:subgroup_id=>sgid,:section=>section) 
                        comp.assign_measures
                        retVal[section][tp_id] = comp
                        eval("section#{section}_has_comp") << tp_id
                    end
                else
                    puts "IT WASN'T THOUGHT TO BE INCLUDED..."
                    # add timepoints that are not included in that section to the no_comp list
                    eval("section#{section}_no_comp") << tp_id
                end
            end
        end
        puts "Section 1 no_comp is #{section1_no_comp}\n"
        puts "Section 2 no_comp is #{section2_no_comp}\n"
        puts "Section 3 no_comp is #{section3_no_comp}\n"
        # for each section, determine if any of the groups don't have comparisons and create them.
        [1,2,3].each do |section|
            if eval("section#{section}_no_comp").length > 0 && all_selected.empty?
                eval("section#{section}_no_comp").each do |nc_id|
                    comp = Comparison.create(:outcome_id=>ocid, :group_id=>nc_id,
                                             :within_or_between=>type, :study_id=>sid,
                                             :extraction_form_id=>efid,:subgroup_id=>sgid, :section=>section)
                    comp.assign_measures
                    retVal[section][nc_id] = comp
                end
            end
        end
        puts "section 1 of retVal has #{retVal[1].keys.length} items in it."
        return retVal
    end

    # get existing comparisons for the current extraction form/study/outcome/timepoints combination.
    # if no comparison exists for one of these points then create a new one.
    # (groups will be timepoints for between-arm, or arms for within-arm)
    def self.create_comparisons(type,group_ids,ocid,sgid=0)
        outcome = Outcome.find(ocid)
        unless outcome.nil?
            unless group_ids.empty?
                group_ids.each do |gid|

                    unless Comparison.where(:group_id=>gid,:within_or_between=>type,
                        :outcome_id=>ocid,:subgroup_id=>sgid,:study_id=>outcome.study_id,
                        :extraction_form_id=>outcome.extraction_form_id).length > 0

                        comp = Comparison.create(:outcome_id=>outcome.id, :subgroup_id=>sgid, :group_id=>gid,
                                                                     :within_or_between=>type, :study_id=>outcome.study_id,
                                                                     :extraction_form_id=>outcome.extraction_form_id)
                        comp.assign_measures
                    end
                end
            end
        end
    end


  # given a hash of comparison values indexed by their group_id, return another hash of measures
  # indexed by the comparison ID
  def self.get_comparison_measures comparisons_hash
    retVal = Hash.new()
    unless comparisons_hash.keys.empty?
        comparisons_hash.keys.each do |key|
            comp = comparisons_hash[key]
            retVal[comp.id] = comp.comparison_measures
        end
    end
    return retVal
  end

  # get_diagnostic_comparison_measures
  # given a hash of diagnostic test comparison values indexed by their section group_id, 
  # return another hash of measures indexed by the comparison ID
  def self.get_diagnostic_comparison_measures comparisons_hash
    retVal = Hash.new()
    unless comparisons_hash[1].keys.empty? && comparisons_hash[2].keys.empty? & comparisons_hash[3].keys.empty?
        [1,2,3].each do |section|
            inner_hash = comparisons_hash[section]      
            inner_hash.keys.each do |key|
                comp = inner_hash[key]
                retVal[comp.id] = comp.comparison_measures
            end
        end
    end
    return retVal
  end


  # given a list of comparisons, return their measures in a hash indexed by comparison ID
  def self.get_within_arm_measures comparisons
    retVal = Hash.new()
    unless comparisons.empty?
        comparisons.each do |c|
            retVal[c.id] = ComparisonMeasure.find(:all, :conditions=>["comparison_id = ?",c.id],:select=>["id","title","description","unit"])
        end
    end
    return retVal
  end


  # given a hash of comparison values indexed by their group_id, return another hash of comparators
  # indexed by the comparison_id
  def self.get_comparators comparisons_hash
    retVal = Hash.new()
    unless comparisons_hash.keys.empty?
        comparisons_hash.keys.each do |key|
            comp = comparisons_hash[key]
            retVal[comp.id] = Comparator.find(:all, :conditions=>["comparison_id=?",comp.id],:select=>["id","comparator"])
        end
    end
    return retVal
  end

    # get_diagnostic_comparators 
    # given a hash of  diagnostic comparison values indexed by their section and group_id, 
    # return another hash of comparators indexed by the comparison_id
    def self.get_diagnostic_comparators comparisons_hash
        retVal = Hash.new()
        all_comparison_ids = comparisons_hash[1].values + comparisons_hash[2].values + comparisons_hash[3].values
        all_comparison_ids = all_comparison_ids.collect{|x| x.id}
        test = Comparator.where(:comparison_id=>all_comparison_ids)
        all_comparators = Comparator.where(:comparison_id=>all_comparison_ids).collect{|x| x.comparator}.uniq
        unless comparisons_hash[1].keys.empty? && comparisons_hash[2].keys.empty? & comparisons_hash[3].keys.empty?
            [1,2,3].each do |section|
                # get the hash of comparisons (by comparison id)
                inner_hash = comparisons_hash[section]      
                inner_hash.keys.each do |key|
                    # get the comparison object
                    comparisonObj = inner_hash[key]
                    retVal[comparisonObj.id] = comparisonObj.comparators
                    my_comparators = retVal[comparisonObj.id].collect{|x| x.comparator}

                    # if this comparison doesn't have one of the comparators in the complete
                    # listing, then create it and add it to the retVal
                    all_comparators.each do |ac|
                        unless my_comparators.include?(ac)
                            new_comp = Comparator.create(:comparison_id=>comparisonObj.id, :comparator=>ac)
                            retVal[comparisonObj.id] << new_comp
                        end
                    end
                end
            end
        end
        return retVal
    end


  # given an array of comparisons, get their comparators and return a hash indexed by comparison id
  def self.get_within_arm_comparators comparisons
    retVal = Hash.new()
    unless comparisons.empty?
        comparisons.each do |c|
            retVal[c.id] = c.comparators
        end
    end
    return retVal
  end


    # given a list of comparison objects, return a set of comparator strings (e.g. 3_5)
    # that represent all comparisons for the outcome and timepoint they represent
    def self.get_all_comparators_for_comparisons comparisons
        retVal = []
        comparisons.each do |c|
            comparators = c.comparators.select("comparator").collect{|x| x.comparator}
            comparators.each do |cp|
                retVal << cp
            end
        end
        retVal.uniq!
        return retVal
    end

  # given an array of comparisons, return a hash indexed by the comparison id that holds
  # all of the comparison datapoints associated with it. The hash should be structured as:
  # datapoints[comparison_id][comparator_id][measure_id] = value
  def self.get_datapoints_for_comparisons comparisons
    # the hash to be returned
    retVal = Hash.new()
    unless comparisons.empty?
        comparisons.each do |comparison|
            retVal[comparison.id] = Hash.new
          measures = comparison.comparison_measures
          comparators = comparison.comparators
          unless comparators.empty?
            comparators.each do |comparator|
                retVal[comparison.id][comparator.id] = Hash.new
                unless measures.empty?
                    measures.each do |measure|
                        datapoints = []
                        unless measure.is_2x2_table? 
                            datapoints = ComparisonDataPoint.where(:comparison_measure_id=>measure.id,:comparator_id=>comparator.id).first
                            unless datapoints.nil?
                                retVal[comparison.id][comparator.id][measure.id] = datapoints
                            end
                        else
                            datapoints = ComparisonDataPoint.where(:comparison_measure_id=>measure.id,:comparator_id=>comparator.id).order("table_cell ASC");
                            unless datapoints.empty? 
                                vals = Hash.new()
                                datapoints.each do |dp|
                                    vals[dp.table_cell] = dp
                                end
                                retVal[comparison.id][comparator.id][measure.id] = vals
                            end
                        end
                    end
                end
              end
          end
        end
      end
    return retVal
  end

  def self.get_datapoints_for_within_arm_comparisons comparisons
    # the hash to be returned
    retVal = Hash.new()
    unless comparisons.empty?
        arms = Study.get_arms(comparisons.first.study_id)
        comparisons.each do |comparison|
            retVal[comparison.id] = Hash.new
          measures = comparison.comparison_measures
          comparators = comparison.comparators
          unless comparators.empty?
            comparators.each do |comparator|
                retVal[comparison.id][comparator.id] = Hash.new
                unless measures.empty?
                    measures.each do |measure|
                        retVal[comparison.id][comparator.id][measure.id] = Hash.new
                        arms.each do |arm|
                            datapoints = ComparisonDataPoint.where(:comparison_measure_id=>measure.id,
                                                                                               :comparator_id=>comparator.id, :arm_id=>arm.id)
                        unless datapoints.empty?
                            datapoints.each do |dp|
                              retVal[comparison.id][comparator.id][measure.id][arm.id] = dp
                            end # end datapoints.each do
                        end # end arms.each do
                        end #end arms.each do
                    end # end measures.each do
                end # end unlses measures.empty
              end #end comparators.each do
          end   # end unless comparators.empty?
        end # end comparisons.each do
      end # end unless comparisons.empty?

    return retVal   
  end


  # given a comparison type, selected timepoint id and outcome id, remove all
  # associated comparison data.
  def self.remove_comparison_data(type, outcome_id, subgroup_id, study_id, extraction_form_id)
    retVal = false

    # find the comparison at that time point and delete it
    comps = Comparison.where(:within_or_between => type, :outcome_id=>outcome_id, :subgroup_id=>subgroup_id, :study_id=>study_id, :extraction_form_id=>extraction_form_id)
    unless comps.empty?
        comps.each do |comp|
            # determine if there are any datapoints with footnotes attached.
            # if there are, we need to update the footnote numbers for other footnotes
            # in the same outcome and subgroup pair.
            dps = comp.comparison_data_points
            unless dps.empty?
                dps.each do |dp|
                    dp_obj = ComparisonDataPoint.find(dp)
                    if dp_obj.footnote_number > 0
                        OutcomeDataEntry.update_footnote_numbers_on_delete(dp_obj.footnote_number, outcome_id, subgroup_id)
                        dp_obj.destroy
                    end
                end
            end
            comp.destroy  # get rid of the comparison and any remaining datapoints
            retVal = true
        end
    end
    return retVal
  end

  # update the display number for a given outcome data entry object. Determine if the
  # new position is above or below that of the previous position, and update surrounding
  # objects in the list accordingly.
  def update_display_number new_position
    current_position = self.display_number
    unless current_position.nil? || current_position == 0
        # if the new position is lower, take all existing with display numbers ranging from
        # new position to current position - 1 and increment them. 
        if new_position < current_position
            displays_to_change = (new_position..current_position-1).to_a
            existing_objs = OutcomeDataEntry.where(:outcome_id=>self.outcome_id, :subgroup_id=>self.subgroup_id,
                                                                                         :extraction_form_id=>self.extraction_form_id,:study_id=>self.study_id,
                                                                                         :display_number=>displays_to_change)
            unless existing_objs.empty?
                existing_objs.each do |eo|
                    eo.display_number = eo.display_number + 1
                    eo.save
                end
            end
        # if the new position is higher, take all existing with display numbers ranging from
        # current position+1 to new position and decrement them. 
        elsif new_position > current_position
            displays_to_change = (current_position+1..new_position).to_a
            existing_objs = OutcomeDataEntry.where(:outcome_id=>self.outcome_id,:subgroup_id=>self.subgroup_id,
                                                                                         :extraction_form_id=>self.extraction_form_id,
                                                                                         :study_id=>self.study_id, :display_number=>displays_to_change)
            unless existing_objs.empty?
                existing_objs.each do |eo|
                    eo.display_number = eo.display_number - 1
                    eo.save
                end
            end
        end
      # if the current_position was nil or zero...
      # (THIS WAS IMPLEMENTED FOR OLD DATABASE ENTRIES THAT DIDN'T HAVE DISPLAY NUMBERS)
      else
        # cycle through existing objects and assign a random order other than the one we just updated
        existing_objs = OutcomeDataEntry.where(:outcome_id=>self.outcome_id, :subgroup_id=>self.subgroup_id,
                                                                                     :extraction_form_id=>self.extraction_form_id,:study_id=>self.study_id)
        iter = 1
        existing_objs.each_with_index do |obj|
            if iter == new_position
                iter += 1
            end
            unless obj.id == self.id
                obj.display_number = iter
                obj.save
                iter += 1
            end
        end

      end
    self.display_number = new_position
    self.save
  end

  # Update the display numbers prior to deleting this outcome data entry. Any objects
  # with display numbers greater than this should be decremented
  def update_display_numbers_for_deletion
    higher_numbers = OutcomeDataEntry.find(:all, :conditions=>["outcome_id = ? AND subgroup_id = ? AND extraction_form_id = ? AND study_id = ? AND display_number > ?", self.outcome_id, self.subgroup_id, self.extraction_form_id, self.study_id, self.display_number])
    unless higher_numbers.empty?
        higher_numbers.each do |obj|
          obj.display_number = obj.display_number - 1
          obj.save  
        end
    end
  end

  #------------------------------------------------------------------------#
  # THE FUNCTION BELOW GATHERS INFORMATION USED TO DISPLAY THE RESULTS     #
  # DATA ENTRY TABLE. IT IS USED BY MANY OF THE OUTCOME DATA ENTRY         #
  # CONTROLLER METHODS.                                                    #
  #                                                                                                                      #
  # @param [Outcome] outcome - the outcome data is entered for                      #
  # @return [Integer] outcome_id,                                                   #  
  #          study_id,                                                     #
  #          extraction_form_id,                                           #
  #          selected_tp_array,                                            #
  #          timepoints,                                                   #
  #          outcome data entries,                                         #
  #          outcome measures,                                             #  
  #          outcome datapoints,                                           #
  #          arms,                                                         #
  #          between-arm comparisons,                                      #
  #          between-arm measures,                                         #
  #          between-arm datapoints,                                       #
  #          between-arm comparators,                                      #
  #          within-arm comparisons,                                       #
  #          within-arm comparators,                                       #
  #          within-arm measures,                                          #
  #          within-arm datapoints                                         #
  #------------------------------------------------------------------------#
  def self.get_information_for_entry_table outcome, subgroup, selected_timepoints
    retVal = Array.new
    subgroup_id = subgroup.nil? ? 0 : subgroup.id
    # convert the selected timepoints string into an array
    selected_tp_array = selected_timepoints.split("_")
    # get the timepoints to be displayed in the table
    timepoints = OutcomeTimepoint.find(:all, :conditions=>["id IN (?)",selected_tp_array],:select=>["id","number","time_unit"])
    # get the outcome data entry objects (nothing to do with comparisons)
    # as well as associated measures and datapoints. timepoints is also re-assigned
    # after being sorted based on the display numbers of the ocdes
    ocdes, timepoints = OutcomeDataEntry.get_ocde_objects(timepoints,outcome.id,outcome.study_id,outcome.extraction_form_id, subgroup_id)
    measures = OutcomeDataEntry.get_measures_for_ocde_array(ocdes,outcome.outcome_type)
    # retrieve the datapoints and footnotes for the table
    sgid = subgroup.nil? ? 0 : subgroup.id
    datapoints = OutcomeDataEntry.get_datapoints_for_ocde_array(ocdes)
    footnotes = outcome.get_foot_notes(sgid)
    # the arms associated with this study
    arms = Arm.find(:all, :conditions=>["study_id = ? AND extraction_form_id = ?",outcome.study_id, outcome.extraction_form_id], :order=>"display_number ASC", :select=>["id","title","description","display_number","extraction_form_id","note","default_num_enrolled","is_intention_to_treat"])    
    # between-arm comparisons.
        btwn_comparisons = OutcomeDataEntry.get_comparisons('between',timepoints,outcome.id,outcome.study_id,outcome.extraction_form_id,subgroup_id)
    # if between-arm comparisons exist, collect the measures, comparators and datapoints associated with them
    unless btwn_comparisons.empty?
        btwn_measures = OutcomeDataEntry.get_comparison_measures(btwn_comparisons)
        btwn_comparators = OutcomeDataEntry.get_comparators(btwn_comparisons) 
        btwn_all_comparators = OutcomeDataEntry.get_all_comparators_for_comparisons(btwn_comparisons.values)
        btwn_datapoints = OutcomeDataEntry.get_datapoints_for_comparisons(btwn_comparisons.values)
      # if no between-arm comparisons exist, set these values to nil
    else
        btwn_measures, btwn_comparators, btwn_all_comparators, btwn_datapoints = [nil,nil,nil,nil]
    end
    wa_comparisons = Comparison.where(:study_id=>outcome.study_id, :outcome_id=>outcome.id, 
                                                                        :extraction_form_id=>outcome.extraction_form_id,
                                                                        :within_or_between=>"within",:subgroup_id=>subgroup_id).order("group_id ASC")
    # if within-arm comparisons exist, collect the measures, comparators and datapoints associated with them
    num_btwn_all_comparators = 0
    unless btwn_comparisons.empty?
        num_btwn_all_comparators = btwn_all_comparators.empty? ? 1 : btwn_all_comparators.length
    end
    # package all values up into one array and return it
    unless wa_comparisons.empty?
        wa_measures = OutcomeDataEntry.get_within_arm_measures(wa_comparisons)
        wa_comparators = OutcomeDataEntry.get_within_arm_comparators(wa_comparisons) 
        wa_datapoints = OutcomeDataEntry.get_datapoints_for_within_arm_comparisons(wa_comparisons)
    else
        wa_measures, wa_comparators, wa_all_comparators, wa_datapoints = [nil,nil,nil,nil]
    end
    retVal = [outcome.id, outcome.study_id, outcome.extraction_form_id, selected_tp_array, timepoints,
              ocdes, measures, datapoints, arms, btwn_comparisons, btwn_measures, btwn_comparators, 
              btwn_all_comparators,num_btwn_all_comparators, btwn_datapoints, wa_comparisons, wa_measures, wa_comparators, 
              wa_all_comparators, wa_datapoints, footnotes]
    return retVal
  end

    #------------------------------------------------------------------------#
    # THE FUNCTION BELOW GATHERS INFORMATION USED TO DISPLAY THE RESULTS     #
    # DATA ENTRY TABLE. IT IS USED BY MANY OF THE OUTCOME DATA ENTRY         #
    # CONTROLLER METHODS.                                                    #
    # @param [Outcome] outcome - the outcome data is entered for             #
    # @return [Integer] outcome_id,                                          #  
    #          study_id,                                                     #
    #          extraction_form_id,                                           #
    #          selected_tp_array,                                            #
    #          timepoints,                                                   #
    #          outcome data entries,                                         #
    #          outcome measures,                                             #  
    #          outcome datapoints,                                           #
    #          arms,                                                         #
    #          between-arm comparisons,                                      #
    #          between-arm measures,                                         #
    #          between-arm datapoints,                                       #
    #          between-arm comparators,                                      #
    #          within-arm comparisons,                                       #
    #          within-arm comparators,                                       #
    #          within-arm measures,                                          #
    #          within-arm datapoints                                         #
    #------------------------------------------------------------------------#
    # get_diagnostic_test_results
    # Given the outcome, subgroup and selected timepoints array, collect diagnostic test comparison data. 
    def self.get_diagnostic_test_results outcome, subgroup, selected_timepoints
        retVal = Array.new()
        tp_hash = Hash.new()
        all_timepoints = outcome.outcome_timepoints
        all_timepoints.each do |tpobj|
            tp_hash[tpobj.id] = tpobj
        end 
        all_timepoints = all_timepoints.collect{|x| x.id}

        # gather some variables for use in queries
        study_id = outcome.study_id
        ef_id = outcome.extraction_form_id
        subgroup_id = subgroup.nil? ? 0 : subgroup.id

        # convert the selected timepoints string into arrays
        # and capture the timepoint objects that we'll need later (any that are selected)
        selected_timepoint_arrays = Hash.new()
        #tp_hash = Hash.new()
        [1,2,3].each do |section|
            selected_timepoint_arrays[section] = selected_timepoints[section].split("_")
        end

        # get the comparison objects, comparators, associated measures and datapoints. There are no
        # standard outcome data entries for diagnostic test objects. 
        comparisons_by_section = OutcomeDataEntry.get_diagnostic_comparisons('between',selected_timepoint_arrays,all_timepoints,outcome.id,study_id,ef_id,subgroup_id)
        # get the measure associated with the list of comparisons
        comparison_measures_hash = OutcomeDataEntry.get_diagnostic_comparison_measures(comparisons_by_section)
        # get the comparators for each comparison
        comparators_hash = OutcomeDataEntry.get_diagnostic_comparators(comparisons_by_section) 
        # get all comparators
        all_comps = comparisons_by_section[1].values + comparisons_by_section[2].values + comparisons_by_section[3].values 
        all_comparators = OutcomeDataEntry.get_all_comparators_for_comparisons(all_comps)
        # get the datapoints hash
        datapoints_hash = OutcomeDataEntry.get_datapoints_for_comparisons(all_comps)

        # get the index and reference tests and their thresholds
        #--------------------------------------------------------
        index_tests = DiagnosticTest.where(:study_id=>study_id, :extraction_form_id=>ef_id, :test_type=>1)
        reference_tests = DiagnosticTest.where(:study_id=>study_id, :extraction_form_id=>ef_id, :test_type=>2)
        thresholds_hash = Hash.new()
        (index_tests + reference_tests).each do |test|
            thresholds_hash[test.id] = DiagnosticTestThreshold.where(:diagnostic_test_id=>test.id)
        end
        footnotes = outcome.get_foot_notes(subgroup_id)

        retVal = [outcome.id, study_id, ef_id, selected_timepoint_arrays, tp_hash,
                  comparisons_by_section, comparators_hash, all_comparators, comparison_measures_hash, 
                  datapoints_hash, index_tests, reference_tests, thresholds_hash, footnotes]
        return retVal
    end

    # collect an array of comparison information that can be passed into the 
  # existing results session variable 
  # @param [Array] ocde_list   - an array of outcome data entry objects that we want to obtain
  #                       comparison information for. The resulting hash should be
  #                       indexed by that object ID
  # @param [String] comp_type   - the type of comparison we're looking for. Can be 
  #                       within, between, etc.
  # @return [Array] BACs        - an array of between-arm comparisons
  # @return [Array] WACs        - an array of within-arm comparisons
  def self.get_existing_comparisons_for_session(ocde_list)
    retVal = {:within=>Hash.new, :between=>Hash.new}
    study_id = 0
    study_arms = []
    outcome_id = 0
    subgroup_id = 0
    timepoints = []
    unless ocde_list.empty?
        ocde_list.each_with_index do |obj,ocde_index|
            # get information from the outcome data entry that can be used to collect
            # outcome comparison data and measures, datapoints, etc.
            ocde_id = obj.id
            oc_id = obj.outcome_id
            ef_id = obj.extraction_form_id
            tp_id = obj.timepoint_id
            s_id = obj.study_id
            display = obj.display_number
            sg_id = obj.subgroup_id
            comp_key = "#{oc_id}_#{sg_id}"  # the key used to reference comparisons in the hash
            if s_id != study_id
                study_id = s_id
                study_arms = Study.get_arms(s_id)
              end
              if oc_id != outcome_id || sg_id != subgroup_id
                outcome_id = oc_id
                timepoints = Outcome.get_timepoint_ids_by_outcome_data_entry(oc_id, sg_id)
            end
            #puts "OCDE Object: #{obj.id}\nOCDE Index: #{ocde_index}\nStudy ID: #{s_id}\nTimepoints: #{timepoints.collect{|x| x.id}.join(", ")}\n"

            # Gather the between-arm and within-arm outcome comparisons
            # the key for the resulting hash is the timepoint id or arm id 
            # depending on the type of comparison

            # TO KEEP PROPER SORTING, I SPLIT THIS INTO A LOOP. HOW CAN WE SORT BY
            # THE PRE-SPECIFIED TIMEPOINT IDs ARRAY?
            ba_comparisons_unsorted = Comparison.where(:within_or_between=>"between",:group_id=>timepoints,
                                                                                :outcome_id=>oc_id,:study_id=>s_id,
                                                                                :extraction_form_id=>ef_id,:subgroup_id=>sg_id).select(["id","group_id"])
                #puts "# BACs UNSORTED: #{ba_comparisons_unsorted.length}\n"
                ba_comparisons = Array.new
                ba_comparisons_unsorted.each do |comp|
                    index = timepoints.index(comp.group_id)
                    ba_comparisons[index] = comp
                end
                #puts "# BACs SORTED: #{ba_comparisons.length}\n"
                wa_comparisons = Comparison.where(:within_or_between=>"within",:group_id=>study_arms.collect{|x| x.display_number},
                                                                                :outcome_id=>oc_id,:study_id=>s_id,
                                                                                :extraction_form_id=>ef_id,:subgroup_id=>sg_id).select("id")
                # Store between-arm comparisons before returning them.
                unless ba_comparisons.empty?

                    comparator_titles = []

                    ba_comparisons.each do |bac|
                    begin
                        unless bac.nil?
                            # For each between-arm comparison, create an array to contain all of the 
                            # comparison elements:
                            # array_pos  desc
                            #     0          the comparison object
                            #     1      an array of comparator ids         
                            #     2          an array of comparison measure objects
                            #     3      a datapoints hash referenced by measureID_comparatorID
                            bac_group = Array.new
                            bac_group << bac
                            comparators = bac.comparators
                            bac_group << comparators.collect{|x| x.id}
                            # gather the titles for comparators for this ocde but only do it once
                            # because they will be the same for all comparisons
                            if comparator_titles.empty?
                              unless comparators.empty?
                                comparators.each do |comparator|
                                    comparator_titles << comparator.to_string('between')
                                end
                              end
                            end
                            # now gather up the comparison measures
                            measures = bac.comparison_measures
                            bac_group << measures

                            # now get the datapoints by measure and comparator
                            datapoints = Hash.new() # keep track of datapoints corresponding to a measure and comparator
                            unless measures.empty?
                                measures.each do |m|
                                    m_id = m.id
                                    unless comparators.empty?
                                        comparators.each do |c|
                                            c_id = c.id
                                            key = "#{m_id}_#{c_id}"
                                            datapoint = ComparisonDataPoint.where(:comparison_measure_id=>m_id, :comparator_id=>c_id).select(["id","value","footnote","is_calculated","footnote_number"])
                                            datapoints[key] = datapoint.empty? ? [] : datapoint.first
                                        end
                                    end
                                end
                            end
                            # add the datapoints hash to the return array
                            bac_group << datapoints

                            # add the bac_group to the retVal hash
                            if !retVal[:between].keys.include?(comp_key)
                                retVal[:between][comp_key] = Array.new()
                            end
                            retVal[:between][comp_key] << bac_group
                        end #end unless bac.nil?
                    rescue Exception=>e
                        puts "AN ERROR OCCURED: #{e.message}\n\n#{e.backtrace}\n\n"
                    end
                    end 
                    # Finally, include the comparator column titles
                    if retVal[:between].keys.include?(comp_key)
                        retVal[:between][comp_key] << comparator_titles
                    end
                end # end unless ba_comparisons.empty?
                #-------------------------------------------------------------
                # Prepare the within-arm comparisons
                # NOTE: This only needs to be done on the first pass through
                # because the within-arm comparisons will be the same for all
                # outcome data entries on this outcome/subgroup
                #-------------------------------------------------------------
                unless (wa_comparisons.empty?) || (ocde_index > 0)
                    wa_comparisons.each do |wac|
                    begin

                        # For each within-arm comparison, create an array to contain all of the 
                        # comparison elements:
                        # array_pos  desc
                        #     0          the comparison object
                        #     1      the comparator id  
                        #     2      the comparator title
                        #     3          an array of comparison measure objects
                        #     4      a datapoints hash referenced by measureID_armID
                        wac_group = Array.new 
                        wac_group << wac                         # the wac object
                        wacomp = wac.comparators.first           # the comparator
                        wacomp_id = wacomp.nil? ? 0 : wacomp.id  # the comparator id
                        wacomp_title = wacomp.nil? ? "--Not Specified--" : wacomp.to_string('within')
                        wac_group << wacomp_id
                        wac_group << wacomp_title

                        # now gather up the within-arm comparison measures
                        wac_measures = wac.comparison_measures
                        wac_group << wac_measures

                        # now get the datapoints by measure, comparator, arm
                        wac_datapoints = Hash.new() # keep track of datapoints corresponding to a measure and comparator
                        unless wac_measures.empty?
                            wac_measures.each do |m|
                                m_id = m.id
                                unless study_arms.empty?
                                    study_arms.each do |sa|
                                        arm_id = sa.id
                                        key = "#{m_id}_#{wacomp_id}_#{arm_id}"
                                        datapoint = ComparisonDataPoint.where(:comparison_measure_id=>m_id, :comparator_id=>wacomp_id, :arm_id=>arm_id).select(["id","value","footnote","is_calculated","footnote_number"])
                                        wac_datapoints[key] = datapoint.empty? ? [] : datapoint.first
                                    end
                                end
                            end
                        end
                        # add the datapoints hash to the return array
                        wac_group << wac_datapoints

                        # add the bac_group to the retVal hash
                        # NOTE that we only add it if it doesn't already exist
                        if !retVal[:within].keys.include?(comp_key)
                            retVal[:within][comp_key] = Array.new()
                        end
                        retVal[:within][comp_key] << wac_group

                    rescue Exception=>e
                        puts "AN ERROR OCCURED: #{e.message}\n\n#{e.backtrace}\n\n"
                    end 
                    end # end wa_comparisons.each do
                end
            end
        end
        return retVal
  end

    # collect an array of diagnostic test comparison information that can be passed into the 
    # existing comparisons session variable 
    # @param [Array] comparison_list   - an array of comparison objects that we want to obtain
    #                       comparison information for. The resulting hash should be
    #                       indexed by that object ID
    # @param [String] comp_type   - the type of comparison we're looking for. Can be 
    #                       within, between, etc. (Always between for Dx tests)
    # @return [Array] BACs        - an array of between-arm comparisons
    def self.get_existing_diagnostic_comparisons_for_session(comparison_list)
        #study_id = 0
        #study_arms = []
        #outcome_id = 0
        #outcome_title = ""
        #subgroup_title = ""
        #subgroup_id = 0
        #timepoints = []
        retVal = Hash.new()
        comparators_hash = Hash.new()
        unless comparison_list.empty?
            # for each comparison in the list
            comparison_list.each do |comparison_obj|
                # determine what part of the hash it will be stored in
                hash_key = "#{comparison_obj.outcome_id}_#{comparison_obj.subgroup_id}"
                unless retVal.keys.include?(hash_key)
                    retVal[hash_key] = []
                end

                # get the comparators
                comparators = comparison_obj.comparators
                # save a copy of the comparator titles to represent the table
                unless comparators_hash.keys.include?(hash_key)
                    comparators_hash[hash_key] = []
                    comparators.each do |comparator|
                        comparators_hash[hash_key] << comparator.to_string('diagnostic')
                    end
                end

                # get the measures
                measures = comparison_obj.comparison_measures

                # to avoid the marshal_dump error, throw everything explicitly into arrays
                measures_array = []
                comparators_array = []
                # now get the datapoints by measure and comparator
                datapoints = Hash.new() # keep track of datapoints corresponding to a measure and comparator
                unless measures.empty?
                    measures.each do |m|
                        measures_array << m
                        unless comparators.empty?
                            comparators.each do |c|
                                unless comparators_array.include?(c.id)
                                    comparators_array << c.id
                                end
                                key = "#{m.id}_#{c.id}"
                                datapoint = ComparisonDataPoint.where(:comparison_measure_id=>m.id, :comparator_id=>c.id).select(["id","value","footnote","is_calculated","footnote_number"]).order(["created_at ASC", "table_cell ASC"])

                                unless datapoints.keys.include?(key)
                                    datapoints[key] = []
                                end
                                # put each individual datapoint into an array       
                                datapoint.each do |dp|
                                    datapoints[key] << dp
                                end
                            end
                        end
                    end
                end
                retVal[hash_key] << [comparison_obj, comparators_array, measures_array, datapoints]
            end # end comparison_list.each do
        end
        return retVal, comparators_hash
    end
=begin
            # FOR EACH COMPARISON IN THE LIST, CREATE AN ARRAY:
            #     0          the comparison object
            #     1      an array of comparator ids         
            #     2          an array of comparison measure objects
            #     3      a datapoints hash referenced by measureID_comparatorID
            comparison_list.each_with_index do |obj,comparison_index|
                # get information from the outcome data entry that can be used to collect
                # outcome comparison data and measures, datapoints, etc.
                comparison_id = obj.id
                oc_id = obj.outcome_id
                ef_id = obj.extraction_form_id
                tp_id = obj.group_id
                s_id = obj.study_id
                sg_id = obj.subgroup_id
                section = obj.section

                if oc_id != outcome_id 
                    oc = Outcome.find(oc_id)
                    outcome_id = oc_id
                    outcome_title = oc.title
                    timepoints = Outcome.get_timepoint_ids_by_comparison(oc_id,sg_id,section)
                end

                if sg_id != subgroup_id
                    subgroup = OutcomeSubgroup.find(sg_id)
                    subgroup_id = sg_id
                    subgroup_title = subgroup.title
                end
                comp_key = "#{oc_id}_#{sg_id}"  # the key used to reference comparisons in the hash

                    # Gather the between-arm comparisons.
                    comparisons_unsorted = Comparison.where(:within_or_between=>"between",:group_id=>timepoints,:outcome_id=>oc_id,:study_id=>s_id,:extraction_form_id=>ef_id,:section=>[1,2,3],:subgroup_id=>sg_id).select(["id","group_id"]).order("group_id ASC, section ASC")

                    # Store between-arm comparisons before returning them.
                    unless comparisons_unsorted.empty?

                        comparator_titles = []
                        puts "STARTING ON THE UNSORTED COMPARISONS...\n"
                        comparisons_unsorted.each do |bac|
                            puts "BAC IS #{bac}\n\n"
                            # For each between-arm comparison, create an array to contain all of the 
                            # comparison elements:
                            # array_pos  desc
                            #     0          the comparison object
                            #     1      an array of comparator ids         
                            #     2          an array of comparison measure objects
                            #     3      a datapoints hash referenced by measureID_comparatorID
                            bac_group = Array.new
                            bac_group << bac
                            comparators = bac.comparators
                            comparator_ids = comparators.collect{|x| x.id}
                            bac_group << comparator_ids
                            # gather the titles for comparators for this ocde but only do it once
                            # because they will be the same for all comparisons
                            if comparator_titles.empty?
                              unless comparators.empty?
                                comparators.each do |comparator|
                                    ctitle = comparator.to_string('diagnostic')
                                    comparator_titles << ctitle
                                end
                              end
                            end
                            # now gather up the comparison measures
                            measures = bac.comparison_measures
                            bac_group << measures

                            # now get the datapoints by measure and comparator
                            datapoints = Hash.new() # keep track of datapoints corresponding to a measure and comparator
                            unless measures.empty?
                                measures.each do |m|
                                    m_id = m.id
                                    unless comparators.empty?
                                        comparators.each do |c|
                                            c_id = c.id
                                            key = "#{m_id}_#{c_id}"
                                            datapoint = ComparisonDataPoint.where(:comparison_measure_id=>m_id, :comparator_id=>c_id).select(["id","value","footnote","is_calculated","footnote_number"])
                                            datapoints[key] = datapoint
                                        end
                                    end
                                end
                            end
                            # add the datapoints hash to the return array
                            bac_group << datapoints

                            # add the bac_group to the retVal hash
                            if !retVal.keys.include?(comp_key)
                                retVal[comp_key] = Array.new()
                            end
                            retVal[comp_key] << bac_group   
                        end # end ba_comparisons.each do
                        # Finally, include the comparator column titles
                        unless comparators_hash.keys.include?(comp_key)
                            comparators_hash[comp_key] = comparator_titles
                        end
                    end #unless ba_comparisons.empty?
                #end # unless retVal.keys.include compkey
            end  #comparison_list.each with index do
        end  # end unless comparison_list.empty?
        rescue Exception => e
            puts "AN ERROR OCCURED: #{e.message}\n\n"
        end
        return retVal, comparators_hash

    end
=end
end
