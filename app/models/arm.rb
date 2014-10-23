# == Schema Information
#
# Table name: arms
#
#  id                    :integer          not null, primary key
#  study_id              :integer
#  title                 :string(255)
#  description           :text
#  display_number        :integer
#  extraction_form_id    :integer
#  created_at            :datetime
#  updated_at            :datetime
#  is_suggested_by_admin :boolean          default(FALSE)
#  note                  :string(255)
#  efarm_id              :integer
#  default_num_enrolled  :integer
#  is_intention_to_treat :boolean          default(TRUE)
#

# this class handles arms in study data entry.
class Arm < ActiveRecord::Base

    belongs_to :study, :touch => true
    has_many :arm_detail_data_points, :dependent=>:destroy
    has_many :baseline_characteristic_data_points, :dependent=>:destroy
    validates :title, :presence => true
    scope :sorted_by_display_number, lambda{|efid, study_id| where("extraction_form_id=? AND study_id=?", efid, study_id).
                select(["id","title"]).
                order("display_number ASC")}

    # get_title
    # get an arm title based on its id
    def self.get_title(arm_id)
        arm = Arm.find(:first, arm_id, :select=>"title")
        return arm.title
    end

    # get_display_number
    # get the maximum arm display number based on a study id and extraction form id
    def get_display_number(study_id, ef_id)
      displays = Arm.where(:study_id=>study_id, :extraction_form_id=>ef_id).collect{|x| x.display_number}
      retVal = 1
      unless displays.empty?
        retVal = displays.max + 1
      end
      return retVal

    end

    # shift_display_numbers
    # used when an arm is deleted.
    # any arms that have a display number greater than the one being deleted should have their display number decreased by 1
    # decrease the former Xth arm's number by 1
    def shift_display_numbers(study_id, ef_id)
        myNum = self.display_number
        high_things = Arm.find(:all, :conditions => ["study_id = ? AND display_number > ? AND extraction_form_id = ?", study_id, myNum, ef_id])
        high_things.each do |thing|
          #print "\n\n\n THING: #{thing.title}\n\n\n"
          tmpNum = thing.display_number
          #print "tmpNum: #{tmpNum.to_s}\n\n"
          thing.display_number = tmpNum - 1
          thing.save
          #print "NEW DISPLAY NUMBER: #{thing.display_number.to_s}\n\n"
        end
    end

    # move_up_this
    # move arm with id = id up 1
    def self.move_up_this(id, study_id, ef_id)
        @this = Arm.find(id.to_i)
        if @this.display_number > 1
            new_num = @this.display_number - 1
            Arm.decrease_other(new_num, study_id, ef_id)
            @this.display_number = new_num
            @this.save
        end
    end

    # decrease other
    # decrease arm display number with display_number = num by 1
    def self.decrease_other(num, study_id, ef_id)
        @other = Arm.where(:study_id => study_id, :extraction_form_id => ef_id, :display_number => num).first
        if !@other.nil?
            @other.display_number = @other.display_number + 1;
            @other.save
        end
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
    #  - proj_id    : the project id
    def self.get_extraction_form_information(ef_list, study_obj, project_id)
        # set up all of the values that we will eventualy return to the controller
        extraction_forms, arms = [Array.new, Array.new]
        included_sections, borrowed_section_names = [Hash.new, Hash.new]
        section_donor_ids, kqs_per_section = [Hash.new, Hash.new]
        arm_descriptions = Hash.new

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
            borrowed_section_names[ef_id] = borrowed.collect{|x| x[0]}
            section_donor_ids[ef_id] = borrowed.collect{|x| x[1]}

            # determine which key questions are addressed in each extraction form section. The values
            # will display in the side study navigation panel as ex:  Study Arms [1,2,3] 
            kqs_per_section[ef_id] = ExtractionFormSection.get_questions_per_section(ef_id,study_obj)

            # get suggested arms from the form and add them to the list
            records = ExtractionFormArm.get_arms_array(ef_id)
            arms += records[0]
          tmp_desc = records[1]
          for key in tmp_desc.keys
            if arm_descriptions[key].nil? || arm_descriptions[key].empty?
                arm_descriptions[key] = tmp_desc[key]
            end
          end
        end # end ef_list.each
        # add the default value to the descriptions list
        arm_descriptions["Choose a suggested arm..."] = ""
        arm_descriptions["Other"] = ""
        # pull in previous arms for the project and add those to arm choices 
        # and descriptions
        previous_arms = Project.get_arms_array(project_id) 
        previous_names = previous_arms[0]
        prev_desc = previous_arms[1]
        for key in prev_desc.keys
            if arm_descriptions[key].nil?
                arm_descriptions[key] = prev_desc[key]
            end
        end
        arms += previous_names
        arms.uniq!
        arms = [["Choose a suggested arm...","Choose a suggested arm..."]] + arms + [["Other","Other"]]
        return [extraction_forms, arms, arm_descriptions, 
                included_sections, borrowed_section_names, section_donor_ids, kqs_per_section]
    end

    # get_ef_arm_options
    # Retrieve a list of arms defined in the extraction forms and/or previously added by other users within the same project
    def self.get_ef_arm_options(study_id, project_id, extraction_form_id)
        study_ids = Project.find(project_id).studies.collect{|s| s.id}
        arms = Arm.where(:study_id=>study_ids, :extraction_form_id=>extraction_form_id).order("title ASC")
        arm_options = ['Choose a suggested arm...']
        arm_descriptions = Hash.new()
        arm_descriptions['Choose a suggested arm...'] = ''
        arms.each do |a|
            unless arm_descriptions.keys.include?(a.title)
                arm_descriptions[a.title] = a.description
                arm_options << a.title
            end
        end
        arm_options << 'Other'
        arm_descriptions['Other'] = ''
        return [arm_options, arm_descriptions]
    end

    # has_data?
    # determine whether or not any data has already been saved for a 
    # particular arm. If Yes, return TRUE, if no, return FALSE
    # also return a message stating where data has been saved (results
    # or comparisons)
    # return a boolean and the locations where data is found in the study
    def has_data?
        retVal = false
        data_locations = Array.new

        # check arm details to see if anything has been entered there
        arm_details = ArmDetailDataPoint.count(:conditions=>["arm_id = ?",self.id])
        if arm_details > 0
            retVal = true
            data_locations << "Arm Details"
        end

        baselines = BaselineCharacteristicDataPoint.count(:conditions=>["arm_id = ?",self.id])
        if baselines > 0
            retVal = true
            data_locations << "Baseline Characteristics"
        end

        # check outcome results to see if any results are defined for this arm
        results = OutcomeDataPoint.where(:arm_id=>self.id)
        if !results.empty?
            retVal = true
            data_locations << "Descriptive Results"
        end

        # get all comparisons between arms for the study this arm belongs to
        between_arms = Comparison.where(:within_or_between=>"between", :study_id=>self.study_id)

        # if the study has between-arm comparisons, check to see if this arm is
        # included in any of the comparators
        unless between_arms.empty?
            between_arms.each do |ba|
                comp = ba.comparators.split("_")
                if comp.include?(self.id.to_s)
                    retVal = true
                    data_locations << "Between-Arm Comparisons"

                end
            end
        end

        # find any within-arm comparisons where this arm is defined as the group id
        within_arms = Comparison.where(:within_or_between=>"within", :study_id=>self.study_id, :group_id=>self.id)

        unless within_arms.empty?
            retVal = true
            data_locations << "Within-Arm Comparisons"
        end

        return retVal, data_locations
    end

    # get_dropdown_options_for_new_arm
    def self.get_dropdown_options_for_new_arm ef_id, study_id
        begin
            retVal = Hash.new()
            title_list = Array.new()
            # get the suggested outcome names and descriptions from the extraction form
            ef_arms = ExtractionFormArm.find(:all, :conditions=>["extraction_form_id = ? ", ef_id], :select=>["name","description"], :order=>"lower(name) ASC")
            retVal["--- Extraction Form Suggestions ---"] = ['','',''] unless ef_arms.empty? 

            ef_arms.each do |efarm|
                title_list << efarm.name.downcase
                # TRYING TO REMOVE SPECIAL CHARACTERS THAT ARE BREAKING THINGS!
                #retVal[efoc.title.scan(/[a-zA-z0-9\s]/).join("")] = [efoc.note.scan(/[a-zA-z0-9\s]/).join(""), "", efoc.outcome_type]
                retVal[efarm.name] = [efarm.description]
            end

            # get all other outcomes that have been added to the project for the same extraction form 
            other_arms = Arm.find(:all, :conditions=>["extraction_form_id = ? AND lower(title) NOT IN (?) AND study_id != ?",ef_id,title_list,study_id], :select=>["title","description"], :order=>"lower(title) ASC")
            retVal["--- Created by Data Extractors ---"] = ['','',''] unless other_arms.empty?
            other_arms.each do |otherarm|
                unless title_list.include?(otherarm.title.downcase)
                    title_list << otherarm.title.downcase
                    retVal[otherarm.title] = [otherarm.description]
                end
            end

            return retVal
        rescue Exception=>e
            puts "encountered an error in get_dropdown_options_for_new_arm: #{e.message}\n\n#{e.backtrace}\n\n"
        end
    end
end
