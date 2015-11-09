# == Schema Information
#
# Table name: extraction_forms
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  creator_id                  :integer
#  notes                       :text
#  adverse_event_display_arms  :boolean          default(TRUE)
#  adverse_event_display_total :boolean          default(TRUE)
#  created_at                  :datetime
#  updated_at                  :datetime
#  project_id                  :integer
#  is_ready                    :boolean
#  bank_id                     :integer
#  is_diagnostic               :boolean          default(FALSE)
#

# An extraction form must answer one or more key questions. 
# The key questions are then answered by a study, which uses the extraction form id to identify data. 
class ExtractionForm < ActiveRecord::Base
    require 'yaml'
    belongs_to :project, :touch=>true
    attr_accessible :title, :project_id, :creator_id
    has_many :design_detail_data_points, :through=>:design_details
    has_many :design_details, :dependent=>:destroy
    has_many :baseline_characteristic_data_points, :through=>:baseline_characteristics
    has_many :baseline_characteristics, :dependent=>:destroy
    has_many :extraction_form_arms, :dependent=>:destroy
    has_many :extraction_form_outcome_names, :dependent=>:destroy
    has_many :extraction_form_sections, :dependent=>:destroy
    has_many :quality_dimension_data_points, :through=>:quality_dimension_fields
    has_many :quality_dimension_fields, :dependent=>:destroy
    has_many :quality_rating_data_points, :through=>:quality_rating_fields
    has_many :quality_rating_fields, :dependent=>:destroy
    has_many :adverse_event_columns, :dependent=>:destroy
    has_many :extraction_form_key_questions, :dependent=>:destroy
    has_many :study_extraction_forms
    has_many :studies, through: :study_extraction_forms


    # determine whether or not the extraction form is capable of being removed
    # 1. does it have any associated studies
    # 2. are any other extraction forms borrowing information from it?
    # @return [boolean] can_be_removed
    def can_be_removed? 
        bool = true

        # find any studies
        studies = StudyExtractionForm.where(:extraction_form_id => self.id).select("id")
        unless studies.empty?
            bool = false
        end

        # find any extraction forms associated with it
        #forms = ExtractionFormSectionCopy.where(:copied_from => self.id).select("id")
        #unless forms.empty?
        #   bool = false
        #end
        return bool
    end

    # is_title_unique_for_user
    # Determine if the proposed new title of the extraction form
    # exists in the database for the same user
    # updating lets us know if it's an update or a new entry
    # @param [string] new_title title string to check if unique
    # @param [User] user user to test title for
    # @param [boolean] updating true if updating extraction form
    # @return [boolean] retVal true if the title is unique, false otherwise
    def is_title_unique_for_user new_title, user, updating
        creator = self.creator_id
        id = self.id
        retVal = true
        query = ""

        if updating
            query = ExtractionForm.count(:conditions=>["lower(title)=? AND id!=? AND project_id=?",new_title.downcase, id, self.project_id])
        else
            query = ExtractionForm.count(:conditions=>["lower(title)=? AND project_id=?",new_title.downcase, self.project_id])
        end

        # if the query count is more than 0, then we know the title is not unique and should return false
        if query > 0
            retVal = false
        end

        return retVal
    end

    # assign_key_questions
    # given a list of key question ids, create extraction form key question objects
    def assign_key_questions kq_ids
        kq_ids.each do |kqid|
            ExtractionFormKeyQuestion.create(:extraction_form_id=>self.id, :key_question_id=>kqid)
        end
    end

    # set_section_options_on_create
    def self.set_section_options_on_create(extraction_form)
        # at the moment we only need to set default options for arm and outcome detail, which will be true
        unless extraction_form.is_diagnostic == true
            EfSectionOption.create(:extraction_form_id=>extraction_form.id, :section=>'arm_detail', :by_arm=>true)            
        else
            EfSectionOption.create(:extraction_form_id=>extraction_form.id, :section=>'diagnostic_test_detail', :by_diagnostic_test=>true)
        end
        EfSectionOption.create(:extraction_form_id=>extraction_form.id, :section=>'outcome_detail', :by_outcome=>true) 

    end

    # is_diagnostic?
    # determine if the extraction form with the provided ID is a diagnostic test form.
    def self.is_diagnostic?(efid)
        retVal = false
        begin
            form = ExtractionForm.find(efid, :select=>["is_diagnostic"])
            if form.is_diagnostic
                retVal = true
            end
        rescue
            puts "Could not find the extraction form with id of #{efid}"
        end
    end

    # includes_section?
    # Determine whether or not an extraction form contains a particular section
    # @params extraction_form_id
    # @params section_name
    # @return boolean - does the form contain this section?
    def self.includes_section?(extraction_form_id, section_name)
        x = ExtractionFormSection.count(:conditions=>["extraction_form_id = ? AND section_name=?",extraction_form_id, section_name])
        return x > 0
    end

    # get_included_sections
    # gather a list of all included sections for a specific extraction form
    def self.get_included_sections(extraction_form_id)
        #ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=? AND included = ?",75,true], :select=>['section_name']).collect{|x| x.section_name}
        return ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=? AND included=?",extraction_form_id,true],:select=>["section_name"]).collect{|x| x.section_name}
    end

    # get_next_question_number
    # return the number of the next question for a section specified by obj_type
    # obj_type should be a string such as DesignDetail, BaselineCharacteristic, etc. and 
    # should correspond to the database table.
    # @param [string] object_type the type of object (model name)
    # @param [integer] extraction_form_id
    # @return [integer] the next question number
    def self.get_next_question_number obj_type, extraction_form_id
        next_num = 1
        last = eval(obj_type).where(:extraction_form_id=>extraction_form_id).order("question_number ASC").last
        unless last.nil?
            next_num = last.question_number + 1
        end
        return next_num
    end

    # shift_questions
    # when a extraction_form creator updates the order of questions in their list, 
    # this method is called
    # @param [integer] current_num the original number of the question choice
    # @param [integer] new_new the number they'd like to change it to
    # @param [string] obj_type DesignDetail or BaselineCharacteristic, etc.
    # @param [integer] template_id the id of the extraction_form they're working on
    def self.shift_questions(current_num, new_num, obj_type, extraction_form_id)
        current_num = current_num.to_i
        new_num = new_num.to_i
        question_to_change = eval(obj_type).where(:extraction_form_id=>extraction_form_id, :question_number=>current_num).first
        unless question_to_change.nil?
            if new_num < current_num
                n = current_num - 1
                while(n > new_num-1)
                    tmp = eval(obj_type).where(:extraction_form_id=>extraction_form_id, :question_number => n).first
                    unless tmp.nil?
                        tmp.question_number = n + 1
                        tmp.save
                    end
                    n-=1
                end
            elsif new_num > current_num
                for n in current_num+1..new_num
                    tmp=eval(obj_type).where(:extraction_form_id=>extraction_form_id,:question_number=>n).first
                    unless tmp.nil?
                        tmp.question_number = n-1
                        tmp.save
                    end
                end
            end
            question_to_change.question_number = new_num
            question_to_change.save
        end
    end

    # update_question_numbers_after_delete
    # after a question is deleted, shift the question numbers to accommodate this
    # @param [string] object
    # @param [integer] object_id
    # @param [integer] extraction_form_id
    def self.update_question_numbers_after_delete(obj, obj_id, extraction_form_id)
        # get the question number of the object being deleted
        q = eval(obj).find(obj_id)
        current = q.question_number.to_i
        max = eval(obj).where(:extraction_form_id=>extraction_form_id).maximum("question_number").to_i
        for n in current+1..max
            tmp = eval(obj).where(:extraction_form_id=>extraction_form_id, :question_number=>n).first
            unless tmp.nil?
                tmp.question_number = n-1
                tmp.save
            end
        end
    end

    # determine which key questions have already been assigned to a given extraction form
    # @param [integer] efid extraction form id
    # @return [array] array of key question ids
    def self.get_assigned_key_questions efid
        kqids = ExtractionFormKeyQuestion.where(:extraction_form_id=>efid).select("key_question_id")
        kqids = kqids.collect{|id| id.key_question_id}
        return kqids
    end

    # get the assigned key questions by question number
    # @param [integer] ef_id extraction form id
    # @return [array] array of question numbers 
    def self.get_assigned_question_numbers ef_id
        retVal = []
        kqs = get_assigned_key_questions(ef_id)
        kqs.each do |kq|
            tmp = KeyQuestion.find(kq, :select=>['question_number'])
            retVal << tmp.question_number
        end
        return retVal.sort
    end

    # get the assigned key questions objects ordered by question number
    # @return [array] key questions array
    def get_assigned_kq_objects
        retVal = []
        kqs = ExtractionForm.get_assigned_key_questions(self.id)
        unless kqs.empty?
            kqs = KeyQuestion.find(kqs,:order=>"question_number ASC")
        end
        return kqs
    end

    # determine which key questions are available to be assigned. they are not available
    # if they have already been assigned to a different form in the same project
    # @param [integer] projid project id
    # @param [integer] efid extraction form id
    # @return [array]
    def self.get_available_questions(projid, efid)
        if efid.nil?
            efid = 0
        end

        # get a list of question ids for all questions in the project
        all_questions = KeyQuestion.where(:project_id=>projid).all
        all_questions = all_questions.collect{|id| id.id}

        # get a list of questions already assigned to other extraction forms
        assigned = ExtractionFormKeyQuestion.find(:all,:conditions=>["extraction_form_id <> ? AND key_question_id IN (?)",efid, all_questions], :select=>["key_question_id", "extraction_form_id"])

        # create an array to hold those that are not previously assigned
        available = [];

        unless assigned.empty?
            # get the key question ids of the previously assigned questions
            assigned_kqs = assigned.collect{|record| record.key_question_id}
            i = 0
            all_questions.each do |q|
                # for each question, if it's already assigned then remove it from the available
                # questions array
                if !assigned_kqs.include?(q)
                    available << q;
                end
                i+=1
            end
        else
            available = all_questions
        end

        kq_map = Hash.new();
        assigned = assigned.collect{|record| [record.key_question_id, record.extraction_form_id]}

        # if there are some assigned, we want to tell the user what extraction form they
        # have already been assigned to
        unless assigned.empty?
            assigned.each do |arr|
                ef = ExtractionForm.find(arr[1], :select=>["title"])
                unless ef.nil?
                    kq_map[arr[0]] = ef.title
                else
                    kq_map[arr[0]] = "ERROR: Could not find extraction form title."
                end
            end
        end
        # create a hash that tells us the title of the form for each previously assigned key question
        return [available, kq_map]
    end

    # create_included_section_fields
    # create a section in the extraction_form_sections table for each page when the extraction form is created
    # @param [integer] extraction_form_id
    def self.create_included_section_fields(extraction_form)

        sections = ['questions','publications','arms','arm_details','design','baselines',
                    'outcomes','outcome_details','results','adverse','quality']
        if extraction_form.is_diagnostic == true
            sections = ['questions','publications','diagnostics','diagnostic_test_details','design','baselines',
                    'outcomes','outcome_details','results','adverse','quality']
        end

        sections.each do |s|
            efs = ExtractionFormSection.new
            efs.extraction_form_id = extraction_form.id
            included = !['questions','publications'].include?(s)
            efs.section_name = s
            efs.included = included
            efs.save
        end
    end


    # create the default questions and fields in the database.
    # pulls default question information from default_questions.yml.
    # @param [integer] extraction_form_id the id of the extraction form to create defaults for
    def self.create_default_questions(ef)
        existing_ef_studies = StudyExtractionForm.count(:conditions=>["extraction_form_id=?",ef.id])
        existing_ef_adverse = AdverseEventColumn.count(:conditions=>["extraction_form_id=?",ef.id])
        existing_ef_design = DesignDetail.count(:conditions=>["extraction_form_id=?",ef.id])
        existing_ef_qualityrating = QualityRatingField.count(:conditions=>["extraction_form_id=?",ef.id])
        #fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/default_questions.yml'
        fn = Rails.root.to_s + "/config/default_questions.yml"
        puts "LOOKING FOR THE DEFAULTS IN #{fn}\n"
        defaults = YAML::load(File.open(fn))

        if (existing_ef_studies == 0) && (existing_ef_adverse == 0) &&  (existing_ef_design == 0) &&  (existing_ef_qualityrating == 0)
            if (defined?(defaults) && !defaults.nil?)
                # design details        
                if !defaults['design-details'].nil?
                    defaults['design-details'].each do |value|
                        @design_detail = DesignDetail.new
                        @design_detail.question = value['question-text']
                        @design_detail.field_type = value['field-type']
                        @design_detail.field_note = value['notes']
                        @design_detail.question_number = value['question-number']
                        @design_detail.extraction_form_id = ef.id
                        @design_detail.save         
                        if defined?(value['options']) && !value['options'].nil?
                            value['options'].each do|v|
                                @design_detail_field = DesignDetailField.new
                                @design_detail_field.design_detail_id = @design_detail.id
                                @design_detail_field.option_text = v['option']
                                @design_detail_field.save
                            end
                        end
                    end
                end

                # adverse event columns
                if !defaults['adverse-event-columns'].nil?          
                    defaults['adverse-event-columns'].each do |adverse_event_column|
                        @new_col = AdverseEventColumn.new
                        @new_col.name = adverse_event_column['column-title']
                        @new_col.description = adverse_event_column['description']
                        @new_col.extraction_form_id = ef.id
                        @new_col.save
                    end
                end

                # quality rating fields
                if !defaults['quality-rating-fields'].nil?              
                    defaults['quality-rating-fields'].each do |quality_rating_field|
                        @new_field = QualityRatingField.new
                        @new_field.rating_item = quality_rating_field['field-title']
                        @new_field.display_number = quality_rating_field['display-number']
                        @new_field.extraction_form_id = ef.id
                        @new_field.save
                    end
                end
            end
        end
    end

    # creates the default outcome measures in the database.
    # pulls the default outcome measure information from default_questions.yml
    # @param [integer] outcome_data_entry_id the id of the outcome data entry to create defaults for    
    def self.create_default_outcome_measures(outcome_data_entry_id)
        fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/default_questions.yml'
        defaults = YAML::load(File.open(fn))

        if (defined?(defaults) && !defaults.nil?)
            # outcome measures          
            if !defaults['outcome-measures'].nil?
                defaults['outcome-measures'].each do |outcome_measure|              
                    @new_measure = OutcomeMeasure.new
                    @new_measure.measure_title = outcome_measure['measure-title']
                    @new_measure.description = outcome_measure['description']
                    @new_measure.unit = outcome_measure['unit']
                    @new_measure.note = outcome_measure['note']
                    @new_measure.measure_type = outcome_measure['measure-type']
                    @new_measure.extraction_form_id = extraction_form_id
                    @new_measure.save
                end
            end
        end
    end


  # a camelcaps function to accept the model as input and return a representation that can be called 
  # with eval to hit the database table.
  # for example: design_detail would give DesignDetail.
  # @return [String] camel_caps_string
  def self.get_camel_caps input
        tmp = input.split("_")
        tmp.each do |x|
            x.downcase!
            x.capitalize!
        end
        return tmp.join("")
  end

    # call this after each extraction_form setting is adjusted. 
    # this will remove all existing columns or re-add them based on the new settings.
    # @param [integer] extraction_form_id extraction form to update
    def self.adverse_event_settings_alter_existing_columns_by_studies(extraction_form_id)
        @study_with_extraction_form = Study.where(:extraction_form_id => extraction_form_id).all
        for study in @study_with_extraction_form
            Study.create_adverse_event_study_columns(study.id)
        end
    end

    # return true if all extraction_form_sections are marked false, i.e. no extraction form sections are included
    # @param [integer] ef_id extraction form id to check
    # @return [boolean] has_no_sections
    def self.no_sections_are_included(ef_id)
        @ef_sections = ExtractionFormSection.where(:extraction_form_id => ef_id).all
        @ef_sections.each do |section|
            if section.included
                return false
            end
        end
        return true
    end

    # return a printable list of the key questions covered by an extraction form
    # @param [integer] ef_id extraction form id
    # @return [string] list of key questions' numbers, in readable format
    def self.get_kqs_covered(ef_id)
        ef_kqs = ExtractionFormKeyQuestion.where(:extraction_form_id => ef_id).all
        str = ""
        for q in ef_kqs
            kq = KeyQuestion.find(q.key_question_id)
            str += kq.question_number.to_s + ", "
        end

        if ef_kqs.length > 0
            str = str[0, str.length - 2]
        end

        return str
    end

    # get the array of arms for an extraction form, based on extraction_form_arms (suggestions).
    # if there are no arms, return ["example arm 1", "example arm 2"] for example table display
    # @param [integer] ef_id extraction form id
    # @return [array] extraction form arms (strings)
    def self.get_arms_array(ef_id)
        @extraction_form = ExtractionForm.find(ef_id)
        @ef_arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
        if @ef_arms.length > 0
            @arr = []
            for arm in @ef_arms
                @arr << arm.name
            end
            return @arr
        else
            return ["Example Arm 1", "Example Arm 2"]
        end
    end

    # get the array of outcomes for an extraction form, based on extraction_form_outcomes (suggestions).
    # if there are no outcomes, return ["example outcome 1", "example outcome 2"] for example table display
    # @param [integer] ef_id extraction form id 
    # @return [array] extraction form outcomes (strings)    
    def self.get_outcomes_array(ef_id)
        @extraction_form = ExtractionForm.find(ef_id)
        @ef_names = ExtractionFormOutcomeName.where(:extraction_form_id => @extraction_form.id).all
        if @ef_names.length > 0
            @arr = []
            for name in @ef_names
                @arr << name.title
            end
            return @arr
        else
            return ["Example Outcome 1", "Example Outcome 2"]
        end
    end

    # toggle_diagnostic
    # when users change the diagnostic test setting after creating an extraction form, 
    # the included sections table may need to be updated. 
    def toggle_diagnostic()
        diagnostic = self.is_diagnostic
        included_sections = ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=?",self.id])
        # if it's diagnostic, set it back to normal
        if diagnostic
            included_sections.each do |is|
                if is.section_name.match(/diagnostic/)
                    if is.section_name.match(/test_details/)
                        is.section_name = 'arm_details'
                    else
                        is.section_name = 'arms'
                    end
                    is.save
                end
            end
            self.is_diagnostic = false

        # otherwise change it to diagnostic
        else
            included_sections.each do |is|
                if is.section_name.match(/arm/)
                    if is.section_name.match(/detail/)
                        is.section_name = 'diagnostic_test_details'
                    else
                        is.section_name = 'diagnostics'
                    end
                    is.save
                end
            end
            self.is_diagnostic = true
        end
        self.save
    end

    # get a list of extraction forms that are borrowing information from a given section 
    # in the form
    # @deprecated possibly?
    # @param [string] section the section name to get borrowed sections from
    # @return [array] an array of extraction form ids
    def get_borrowers(section)
        borrowers = ExtractionFormSectionCopy.where(:section_name=>section, :copied_from=>self.id).select("copied_to")
        return borrowers.collect{|x| x.copied_to}
    end

    # remove all data from an extraction form for a particular study. 
    # includes: arms, design details, baseline characteristics, outcomes, results, comparisons, adverse events, study quality
    # @param [integer] ef_id extraction form id
    # @param [integer] study_id study id
    def self.remove_extracted_data(ef_id, study_id)
        Arm.where(:study_id=>study_id, :extraction_form_id=>ef_id).destroy_all
        DesignDetailDataPoint.where(:study_id=>study_id, :extraction_form_id=>ef_id).destroy_all
        BaselineCharacteristicDataPoint.where(:study_id=>study_id, :extraction_form_id=>ef_id).destroy_all
        Outcome.where(:study_id=>study_id, :extraction_form_id=>ef_id).destroy_all
        OutcomeDataEntry.where(:study_id=>study_id, :extraction_form_id=>ef_id).destroy_all
        Comparison.where(:study_id=>study_id,:extraction_form_id=>ef_id).destroy_all
        AdverseEvent.where(:study_id=>study_id,:extraction_form_id=>ef_id).destroy_all
        QualityRatingDataPoint.where(:study_id=>study_id,:extraction_form_id=>ef_id).destroy_all
        QualityDimensionDataPoint.where(:study_id=>study_id,:extraction_form_id=>ef_id).destroy_all
    end

    # copy_project_efs
    # Create duplicate extraction form entries in the database for a list of 
    # key question IDs. 
    # @params [integer] user_id - the id of the user copying the form
    # @params [hash] kq_id_map  - a map of old key question ID to new key question ID
    #                                                       allows us to assign the new EF object to the new KQ object
    # @params[hash] project_id_map - provide a link between old and new project ids
    # @return [hash] ef_id_map  - a map of old extraction form ID to new extraction form ID
    def self.copy_project_efs(user_id, kq_id_map, old_project_id, new_project_id)
        # keep track of newly created identifiers that will be used to copy additional
        # data from the studies
        ef_id_map = Hash.new()    # extraction form ID mapping
        design_detail_id_map = Hash.new()    # design detail mappings
        design_detail_field_map = Hash.new()
        baseline_characteristic_id_map = Hash.new()    # baseline characteristic mappings
        baseline_characteristic_field_map = Hash.new()
        outcome_detail_id_map = Hash.new()    # outcome detail mappings
        outcome_detail_field_map = Hash.new()
        arm_detail_id_map = Hash.new()    # arm detail mappings
        arm_detail_field_map = Hash.new()
        qual_id_map = Hash.new()  # quality mappings
        adverse_heading_id_map = Hash.new()  # adverse event mapping

        # find all extraction forms associated with the project being copied and 
        # copy them. Update the project id and also find all related information for the
        # extraction form, such as arms, outcomes, design details, baseline characteristics, etc.
        #----------------------------------------------------------------------------------------
        efs_to_copy = ExtractionForm.where(:project_id=>old_project_id)
        puts "Found #{efs_to_copy.length} forms to copy.\n\n"

        efs_to_copy.each do |ef|
            begin
            #puts "copying form with title of #{ef.title}\n\n"
            # clone the form and change fields before saving
            new_ef = ef.clone
            new_ef.updated_at = Time.now
            new_ef.project_id = new_project_id
            new_ef.created_at = Time.now()
            new_ef.creator_id = user_id
            new_ef.save
            #puts "the new copy has the id of #{new_ef.id}\n\n"
            # map the old ef id to the new ef id
            ef_id_map[ef.id] = new_ef.id

            #puts "setting up extraction form key questions..."
            # set up the extraction form key questions table for the new EF
            #--------------------------------------------------------------
            kqs = ExtractionFormKeyQuestion.where(:extraction_form_id=>ef.id).select("key_question_id")
            kqs.each do |kq|
                original_kq_id = kq.key_question_id
                new_kq_id = kq_id_map[original_kq_id]
                ExtractionFormKeyQuestion.create(:extraction_form_id=>new_ef.id, :key_question_id=>new_kq_id)
            end
            #puts "done.\n\n"

            #puts "setting up extraction form sections..."
            # copy extraction form sections
            #--------------------
            sections = ExtractionFormSection.where(:extraction_form_id=>ef.id)
            sections.each do |section|
                new_section = section.clone
                new_section.extraction_form_id = new_ef.id
                new_section.created_at = Time.now
                new_section.updated_at = Time.now
                new_section.save
            end
            #puts "setting up suggested arms..."
            # copy suggested arms
            #--------------------
            arms = ExtractionFormArm.where(:extraction_form_id=>ef.id)
            arms.each do |arm|
                new_arm = arm.clone
                new_arm.extraction_form_id = new_ef.id
                new_arm.save
            end

=begin
            # copy arm detail questions
            #----------------------------------------
            #puts "setting up baseline characteristics..."
            ads = ArmDetail.where(:extraction_form_id=>ef.id)
            ads.each do |ad|
                # clone the design detail
                new_ad = ad.clone
                new_ad.created_at = Time.now
                new_ad.updated_at = Time.now
                new_ad.extraction_form_id = new_ef.id
                new_ad.save
                ad_id_map[ad.id] = new_ad.id

                # find any baseline characteristic fields and clone them as well
                ad_fields = ArmDetailField.where(:arm_detail_id=>ad.id)
                ad_fields.each do |field|
                    new_field = field.clone
                    new_field.updated_at = Time.now
                    new_field.created_at = Time.now
                    new_field.arm_detail_id = new_ad.id
                    new_field.save
                    ad_field_map[field.id] = new_field.id
                end
            end

            #puts "done.\n\n"
            # copy design details questions
            #-------------------------------
            #puts "setting up design details..."
            dds = DesignDetail.where(:extraction_form_id=>ef.id)
            dds.each do |dd|
                # clone the design detail
                new_dd = dd.clone
                new_dd.created_at = Time.now
                new_dd.updated_at = Time.now
                new_dd.extraction_form_id = new_ef.id
                new_dd.save
                dd_id_map[dd.id] = new_dd.id

                # find any design detail fields and clone them as well
                dd_fields = DesignDetailField.where(:design_detail_id=>dd.id)
                dd_fields.each do |field|
                    new_field = field.clone
                    new_field.updated_at = Time.now
                    new_field.created_at = Time.now
                    new_field.design_detail_id = new_dd.id
                    new_field.save
                    dd_field_map[field.id] = new_field.id
                end
            end
            #puts "done.\n\n"

            # copy baseline characteristics questions
            #----------------------------------------
            #puts "setting up baseline characteristics..."
            bcs = BaselineCharacteristic.where(:extraction_form_id=>ef.id)
            bcs.each do |bc|
                # clone the design detail
                new_bc = bc.clone
                new_bc.created_at = Time.now
                new_bc.updated_at = Time.now
                new_bc.extraction_form_id = new_ef.id
                new_bc.save
                bc_id_map[bc.id] = new_bc.id

                # find any baseline characteristic fields and clone them as well
                bc_fields = BaselineCharacteristicField.where(:baseline_characteristic_id=>bc.id)
                bc_fields.each do |field|
                    new_field = field.clone
                    new_field.updated_at = Time.now
                    new_field.created_at = Time.now
                    new_field.baseline_characteristic_id = new_bc.id
                    new_field.save
                    bc_field_map[field.id] = new_field.id
                end
            end

            # copy outcome detail questions
            #-------------------------------
            #puts "setting up outcome details..."
            ods = OutcomeDetail.where(:extraction_form_id=>ef.id)
            ods.each do |od|
                # clone the design detail
                new_od = od.clone
                new_od.created_at = Time.now
                new_od.updated_at = Time.now
                new_od.extraction_form_id = new_ef.id
                new_od.save
                od_id_map[od.id] = new_od.id

                # find any design detail fields and clone them as well
                od_fields = OutcomeDetailField.where(:outcome_detail_id=>od.id)
                od_fields.each do |field|
                    new_field = field.clone
                    new_field.updated_at = Time.now
                    new_field.created_at = Time.now
                    new_field.outcome_detail_id = new_od.id
                    new_field.save
                    od_field_map[field.id] = new_field.id
                end
            end
=end
            # Copy the question-builder style sections
            # design_detail, arm_detail, baseline_characteristic, outcome_detail, diagnostic_test_detail
            sections = ["design_detail","arm_detail","outcome_detail","baseline_characteristic","diagnostic_test_detail"]
            field_id_map = Hash.new()
            sections.each do |section|
                
                model = section.split("_").map{|x| x.capitalize}.join("")
                puts "---------------------------\n"
                puts "---------------------------\n"
                puts "STARTING ON #{section} -- #{model}\n\n"
                questions = eval("#{model}").find(:all, :conditions=>["extraction_form_id=?",ef.id])
                fields = eval("#{model}Field").find(:all, :conditions=>["#{section}_id IN (?)",questions.collect{|x| x.id}])
                questions.each do |q|
                    # clone the question
                    myq = eval("#{model}").create(:extraction_form_id => new_ef.id, :question=>q.question, 
                        :field_type=>q.field_type, :question_number=>q.question_number, 
                        :instruction=>q.instruction, :is_matrix=>q.is_matrix, :include_other_as_option=>q.include_other_as_option)
                    eval("#{section}_id_map")[q.id] = myq.id
                    # find any associated fields and clone them as well
                    myfields = fields.select{|f| f["#{section}_id"] == q.id}
                    unless myfields.empty?
                        myfields.each do |field|
                            newField = eval("#{model}Field").create("#{section}_id"=>myq.id, :option_text=>field.option_text,
                                :subquestion=>field.subquestion,:has_subquestion=>field.has_subquestion,
                                :row_number=>field.row_number,:column_number=>field.column_number)
                            eval("#{section}_field_map")[field.id] = newField.id
                            # field_id_map[field.id] = newField.id # record the mapping between old and new ids
                        end
                    end
                    
                    if myq.field_type == 'matrix_select' && !myfields.empty?
                        # finally, copy any matrix dropdown options if necessary
                        dropdown_options = MatrixDropdownOption.find(:all, :conditions=>["row_id in (?) or column_id in (?)",
                                                                     myfields.collect{|mf| mf.id}, myfields.collect{|mf| mf.id}]).uniq
                        dropdown_options.each do |dd|
                            MatrixDropdownOption.create(:row_id=>eval("#{section}_field_map")[dd.row_id], :column_id=>eval("#{section}_field_map")[dd.column_id],
                                :option_text=>dd.option_text, :option_number=>dd.option_number, :model_name=>dd.model_name)

                        end
                    end
                end
            end # Done copying question-based sections

            #puts "done.\n\n"
            #puts "done.\n\n"
            # copy suggested outcomes
            #------------------------
            #puts "setting up suggested outcomes..."
            outcomes = ExtractionFormOutcomeName.where(:extraction_form_id=>ef.id)
            outcomes.each do |oc|
                new_oc = oc.clone
                new_oc.updated_at = Time.now
                new_oc.created_at = Time.now
                new_oc.extraction_form_id = new_ef.id
                new_oc.save
            end
            #puts "done.\n\n"
            # copy adverse event settings and table headings
            #-----------------------------------------------
            #puts "setting up adverse event columns..."
            headings = AdverseEventColumn.where(:extraction_form_id=>ef.id)
            headings.each do |heading|
                new_heading = heading.clone
                new_heading.created_at = Time.now
                new_heading.updated_at = Time.now
                new_heading.extraction_form_id = new_ef.id
                new_heading.save
                adverse_heading_id_map[heading.id] = new_heading.id
            end
            #puts "done.\n\n"
            # copy quality dimensions and ratings
            #------------------------------------
            #puts "setting up quality dimensions and ratings..."
            dimensions = QualityDimensionField.where(:extraction_form_id=>ef.id)
            dimensions.each do |dimension|
                new_dimension = dimension.clone
                new_dimension.updated_at = Time.now
                new_dimension.created_at = Time.now
                new_dimension.extraction_form_id = new_ef.id
                new_dimension.save
                qual_id_map[dimension.id] = new_dimension.id
            end

            ratings = QualityRatingField.where(:extraction_form_id=>ef.id)
            ratings.each do |rating|
                new_rating = rating.clone
                new_rating.updated_at = Time.now
                new_rating.created_at = Time.now
                new_rating.extraction_form_id = new_ef.id
                new_rating.save
            end
            #puts "done.\n\n"
            rescue Exception => e
                puts e.message  
                puts e.backtrace.inspect  
            end
        end
        return ef_id_map, arm_detail_id_map, arm_detail_field_map, design_detail_id_map, design_detail_field_map, baseline_characteristic_id_map, baseline_characteristic_field_map, outcome_detail_id_map, outcome_detail_field_map, adverse_heading_id_map, qual_id_map
    end


    # send_to_bank
    # Create an extraction form template based on the one submitted by the user. It
    # will be stored in the bank for future use by various individuals depending on 
    # the parameters passed in by the user. 
    # @params [integer] user_id - the id of the user creating the template
    # @params [string] title - the title assigned to the new template
    # @params [boolean] show_to_team - whether or not team members should have access to it
    # @params [boolean] show_to_world - whether or not it should be made completely public
    # @return [boolean] success - Whether or not the operation was a success
    def send_to_bank(user_id, title, description, show_to_team, show_to_world)
        
        # begin by creating a new extraction form template
        eft = ExtractionFormTemplate.create(:template_form_id=>self.id, 
                :title=>title, :description=>description, 
                :creator_id=>user_id, :notes=>self.notes,
                :adverse_event_display_arms=>self.adverse_event_display_arms,
                :adverse_event_display_total=>self.adverse_event_display_total,
                :show_to_world => show_to_world, :show_to_local=>show_to_team,
                :created_at => Time.now(), :updated_at => Time.now());

        # copy extraction form sections
        #--------------------
        sections = ExtractionFormSection.where(:extraction_form_id=>self.id)
        sections.each do |section|
            EftSection.create(:extraction_form_template_id => eft.id, :section_name=>section.section_name,
                                                :included => section.included)
        end

        # copy suggested arms
        #--------------------
        arms = ExtractionFormArm.where(:extraction_form_id=>self.id)
        arms.each do |arm|
            EftArm.create(:extraction_form_template_id=>eft.id,:name=>arm.name,
                                        :description=>arm.description,:note=>arm.note)
        end
        begin
        # Copy the question-builder style sections
        # design_detail, arm_detail, baseline_characteristic, outcome_detail, diagnostic_test_detail
        sections = ["design_detail","arm_detail","outcome_detail","baseline_characteristic","diagnostic_test_detail"]
        field_id_map = Hash.new()
        sections.each do |section|
            
            model = section.split("_").map{|x| x.capitalize}.join("")
            puts "---------------------------\n"
            puts "---------------------------\n"
            puts "STARTING ON #{section} -- #{model}\n\n"
            questions = eval("#{model}").find(:all, :conditions=>["extraction_form_id=?",self.id])
            fields = eval("#{model}Field").find(:all, :conditions=>["#{section}_id IN (?)",questions.collect{|x| x.id}])
            questions.each do |q|
                # clone the question
                myq = eval("Eft#{model}").create(:extraction_form_template_id => eft.id, :question=>q.question, 
                    :field_type=>q.field_type, :question_number=>q.question_number, 
                    :instruction=>q.instruction, :is_matrix=>q.is_matrix, :include_other_as_option=>q.include_other_as_option)

                # find any associated fields and clone them as well
                myfields = fields.select{|f| f["#{section}_id"] == q.id}
                unless myfields.empty?
                    myfields.each do |field|
                        puts ("OPTION TEXT: "+field.option_text)
                        newField = eval("Eft#{model}Field").create("eft_#{section}_id"=>myq.id, :option_text=>"#{field.option_text}",
                            :subquestion=>field.subquestion,:has_subquestion=>field.has_subquestion,
                            :row_number=>field.row_number,:column_number=>field.column_number)
                        field_id_map[field.id] = newField.id # record the mapping between old and new ids
                    end
                end
                
                if myq.field_type == 'matrix_select' && !myfields.empty?
                    # finally, copy any matrix dropdown options if necessary
                    dropdown_options = MatrixDropdownOption.find(:all, :conditions=>["row_id in (?) or column_id in (?)",
                                                                 myfields.collect{|mf| mf.id}, myfields.collect{|mf| mf.id}]).uniq
                    dropdown_options.each do |dd|
                        EftMatrixDropdownOption.create(:row_id=>field_id_map[dd.row_id], :column_id=>field_id_map[dd.column_id],
                            :option_text=>"#{dd.option_text}", :option_number=>dd.option_number, :model_name=>dd.model_name)

                    end
                end
            end
        end # Done copying question-based sections
        rescue Exception=>e 
            puts "Caught: #{e.message}\n\n#{e.backtrace}\n\n"
        end

        # copy suggested outcomes
        #------------------------
        outcomes = ExtractionFormOutcomeName.where(:extraction_form_id=>self.id)
        outcomes.each do |oc|
            EftOutcomeName.create(:extraction_form_template_id=>eft.id, :title=>oc.title, 
                    :note=>oc.note, :outcome_type=>oc.outcome_type)
        end

        # copy adverse event settings and table headings
        #-----------------------------------------------
        headings = AdverseEventColumn.where(:extraction_form_id=>self.id)
        headings.each do |heading|
            EftAdverseEventColumn.create(:extraction_form_template_id=>eft.id, :name=>heading.name,
                    :description=>heading.description)
        end

        # copy quality dimensions and ratings
        #------------------------------------
        dimensions = QualityDimensionField.where(:extraction_form_id=>self.id)
        dimensions.each do |dimension|
            EftQualityDimensionField.create(:extraction_form_template_id=>eft.id, :title=>dimension.title,
                    :field_notes=>dimension.field_notes)
        end

        ratings = QualityRatingField.where(:extraction_form_id=>self.id)
        ratings.each do |rating|
            EftQualityRatingField.create(:extraction_form_template_id=>eft.id, :rating_item=>rating.rating_item,
                    :display_number=>rating.display_number)
        end

        # set the bank_id in the extraction form object
        self.bank_id = eft.id
        self.save
    end

    # Returns a nested Array used to create options for select in view template
    # @return [ ["Design Details", :DesignDetail],
    #           ["Baseline Characteristics", :BaselineCharacteristic],
    #           ["Outcome Details", :OutcomeDetail] ]
    def section_options_for_select_simple_import
        selections = Array.new

        sections = self.included_sections
        selections << ["Design Details", :DesignDetail] if sections.include? :DesignDetail
        selections << ["Arms", :Arm] if sections.include? :ArmDetail
        selections << ["Arm Details", :ArmDetail] if sections.include? :ArmDetail
        selections << ["Diagnostics", :DiagnosticTest] if sections.include? :DiagnosticTestDetail
        selections << ["Diagnostic Tests", :DiagnosticTestDetail] if sections.include? :DiagnosticTestDetail
        selections << ["Baseline Characteristics", :BaselineCharacteristic] if sections.include? :BaselineCharacteristic
        selections << ["Outcomes", :Outcome] if sections.include? :OutcomeDetail
        selections << ["Outcome Details", :OutcomeDetail] if sections.include? :OutcomeDetail
        selections << ["Adverse Events", :AdverseEvent] if sections.include? :AdverseEvent

        return selections
    end

    # Returns an array of symbols for each section that is included in the extraction form.
    # @return [lof_symbols]
    def included_sections
        section_map = { 'design' => :DesignDetail,
                        'arm_details' => :ArmDetail,
                        'diagnostics' => :DiagnosticTestDetail,
                        'baselines' => :BaselineCharacteristic,
                        'outcome_details' => :OutcomeDetail,
                        'adverse' => :AdverseEvent }
        return self.extraction_form_sections.map { |efs| section_map[efs.section_name] if efs.included? } - [nil]
    end
end
