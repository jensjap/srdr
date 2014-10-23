# == Schema Information
#
# Table name: extraction_form_templates
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  creator_id                  :integer
#  notes                       :text
#  adverse_event_display_arms  :boolean
#  adverse_event_display_total :boolean
#  show_to_local               :boolean
#  show_to_world               :boolean
#  created_at                  :datetime
#  updated_at                  :datetime
#  description                 :text
#  template_form_id            :integer
#

class ExtractionFormTemplate < ActiveRecord::Base
	has_many :eft_adverse_event_columns, :dependent=>:destroy
	has_many :eft_arms, :dependent=>:destroy
	has_many :eft_baseline_characteristics, :dependent=>:destroy
	has_many :eft_design_details, :dependent=>:destroy
	has_many :eft_arm_details, :dependent=>:destroy
	has_many :eft_outcome_details, :dependent=>:destroy
	has_many :eft_diagnostic_test_details, :dependent=>:destroy
	has_many :eft_outcome_names, :dependent=>:destroy
	has_many :eft_quality_dimension_fields, :dependent=>:destroy
	has_many :eft_quality_rating_fields, :dependent=>:destroy
	has_many :eft_sections, :dependent=>:destroy

	# remove_from_bank
	# Remove the extraction form template form the form bank and reset the bank_id of the 
	# associated extraction form to 0. 
	def remove_from_bank
		# get the extraction form associated with it and update the bank_id back to nil
		begin
			ef = ExtractionForm.find(self.template_form_id)
			ef.bank_id = nil
			ef.save
		rescue Exception => e
			puts "Tried to update the extraction form associated with form template #{self.id} but it does not exist!"
		ensure
			# remove the template and all associated objects from the bank
			self.destroy();
		end
	end

	# assign_to_project
	# Create a copy of the form template and save it as an extraction form object
	# belonging to the specified project. Also assign it a title provided by the user
	# and record the ID of the new creator.
	def assign_to_project project_id, title, user_id
		# create the new form
		#---------------------
		ef = ExtractionForm.create(:title=>title, :creator_id=>user_id, :notes=>self.notes,
					:project_id=>project_id, :is_ready=>false,
		    	:adverse_event_display_arms=>self.adverse_event_display_arms,
		    	:adverse_event_display_total=>self.adverse_event_display_total)
		
		# assign form sections
		#---------------------
		sections = self.eft_sections
		sections.each do |sect|
			ExtractionFormSection.create(:extraction_form_id=>ef.id, :section_name=>sect.section_name,
					:included=>sect.included)
		end
		# assign form arms
		#---------------------
		arms = self.eft_arms
		arms.each do |arm|
			ExtractionFormArm.create(:extraction_form_id=>ef.id, :name=>arm.name, :description=>arm.description,
					:note=>arm.note)
		end
		
		# Copy the question-builder style sections
        # design_detail, arm_detail, baseline_characteristic, outcome_detail, diagnostic_test_detail
        sections = ["design_detail","arm_detail","outcome_detail","baseline_characteristic","diagnostic_test_detail"] 
        field_id_map = Hash.new()
        sections.each do |section|
            model = section.split("_").map{|x| x.capitalize}.join("")
            puts "---------------------------\n"
            puts "---------------------------\n"
            puts "STARTING TO ADD #{section} -- #{model}\n\n"
            questions = eval("Eft#{model}").find(:all, :conditions=>["extraction_form_template_id=?",self.id])
            fields = eval("Eft#{model}Field").find(:all, :conditions=>["eft_#{section}_id IN (?)",questions.collect{|x| x.id}])
            questions.each do |q|
                # clone the question
                myq = eval("#{model}").create(:extraction_form_id => ef.id, :question=>q.question, 
                    :field_type=>q.field_type, :question_number=>q.question_number, 
                    :instruction=>q.instruction, :is_matrix=>q.is_matrix, :include_other_as_option=>q.include_other_as_option)

                # find any associated fields and clone them as well
                myfields = fields.select{|f| f["eft_#{section}_id"] == q.id}
                unless myfields.empty?
                    myfields.each do |field|
                        newField = eval("#{model}Field").create("#{section}_id"=>myq.id, :option_text=>field.option_text,
                            :subquestion=>field.subquestion,:has_subquestion=>field.has_subquestion,
                            :row_number=>field.row_number,:column_number=>field.column_number)
                        field_id_map[field.id] = newField.id # record the mapping between old and new ids
                    end
                end
                
                if myq.field_type == 'matrix_select' && !myfields.empty?
                    # finally, copy any matrix dropdown options if necessary
                    dropdown_options = EftMatrixDropdownOption.find(:all, :conditions=>["row_id in (?) or column_id in (?)",
                                                                 myfields.collect{|mf| mf.id}, myfields.collect{|mf| mf.id}]).uniq
                    dropdown_options.each do |dd|
                        MatrixDropdownOption.create(:row_id=>field_id_map[dd.row_id], :column_id=>field_id_map[dd.column_id],
                            :option_text=>dd.option_text, :option_number=>dd.option_number, :model_name=>dd.model_name)

                    end
                end
            end
        end # Done copying question-based sections

		# assign outcome names
		#---------------------
		outcomes = self.eft_outcome_names
		outcomes.each do |oc|
			ExtractionFormOutcomeName.create(:extraction_form_id=>ef.id, :title=>oc.title, 
					:note=>oc.note, :outcome_type=>oc.outcome_type)
		end
		# assign adverse event columns
		#------------------------------
		adverse_columns = self.eft_adverse_event_columns
		adverse_columns.each do |aec|
			AdverseEventColumn.create(:extraction_form_id=>ef.id, :name=>aec.name,
					:description=>aec.description)
		end
		# assign quality dimensions
		#----------------------------
		qual_dimensions = self.eft_quality_dimension_fields
		qual_dimensions.each do |qd|
			QualityDimensionField.create(:extraction_form_id=>ef.id, :title=>qd.title, 
					:field_notes=>qd.field_notes)
		end
		# assign quality ratings
		#-------------------------
		qual_ratings = self.eft_quality_rating_fields
		qual_ratings.each do |qr|
			QualityRatingField.create(:extraction_form_id=>ef.id, :rating_item=>qr.rating_item, 
			:display_number=>qr.display_number)
		end
		return ef		
	end

	# get_user_forms
	# Return a list of extraction form templates that were created by the current user.
	def self.get_user_forms user_id
			forms = ExtractionFormTemplate.where(:creator_id=>user_id)
			return forms
	end

	# get_collaborator_forms
	# Return a list of extraction form templates that were created by individuals that the 
	# current user collaborates with or who belong to the same team.
	def self.get_collaborator_forms user_id, collaborator_ids
			forms = ExtractionFormTemplate.where(:creator_id=>collaborator_ids)
			return forms
	end

	# get_world_forms
	# Return a list of all extraction form templates currently available in the system. Exclude
	# any that were created by the current user or by those who collaborate with the current user
	def self.get_world_forms user_id, collaborator_ids
		begin
			collaborator_ids << user_id
			forms = ExtractionFormTemplate.find(:all, :conditions=>["creator_id NOT IN (?)", collaborator_ids])
			return forms
		rescue
			return []
		end
	end

	# templates_available?
	# Determine whether or not there are templates available for a user to choose from. 
	# This is the case if there are either user forms, collaborator forms or world forms.
	def self.templates_available? user
		retVal = false
		# check if this user has any form templates of his own
		if ExtractionFormTemplate.get_user_forms(user.id).length > 0
			retVal = true
		end
		# if the user does not have form templates of their own, determine if their 
		# collaborators have saved any templates. If they have not, check if anyone else
		# has saved any.
		if retVal == false
			collabs = User.get_collaborator_ids(user.id)
			if ExtractionFormTemplate.get_collaborator_forms(user.id, collabs).length > 0
				retVal = true
			elsif ExtractionFormTemplate.get_world_forms(user.id, collabs).length > 0
				retVal = true
			end
		end
		return retVal
	end
		
end
