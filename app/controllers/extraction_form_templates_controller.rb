class ExtractionFormTemplatesController < ApplicationController
	layout "two_column_main"
	# index
	# Show the extraction form templates currently available for use on projects.
	# Separate the list into three groups: My Forms, Collaborator's Forms, All Forms
	def index
		collaborator_ids =  User.get_collaborator_ids(current_user.id)
		@my_forms = ExtractionFormTemplate.get_user_forms(current_user.id)
		@collab_forms = ExtractionFormTemplate.get_collaborator_forms(current_user.id, collaborator_ids)
		@world_forms = ExtractionFormTemplate.get_world_forms(current_user.id, collaborator_ids)
		@page_title = "The Extraction Form Bank"
	end

	# preview
	# Show the user a preview of the extraction form template that they're interested in. Open the
	# preview into a new window so that users may choose to keep it open without it interfering with 
	# other work on the site.
	def preview
		@template = ExtractionFormTemplate.find(params[:eft_id])
		@eft_id = "eft#{params[:eft_id]}"
		@sections = @template.eft_sections.collect{|x| x.section_name}
		@arms = @template.eft_arms
		@design_details = @template.eft_design_details.order("question_number ASC")
		@baseline_characteristics = @template.eft_baseline_characteristics.order("question_number ASC")
		@arm_details = @template.eft_arm_details.order("question_number ASC")
		@outcome_details = @template.eft_outcome_details.order("question_number ASC")
		@outcomes = @template.eft_outcome_names
		@adverse_columns = @template.eft_adverse_event_columns
		@quality_dimensions = @template.eft_quality_dimension_fields
		@quality_ratings = @template.eft_quality_rating_fields.order("display_number ASC")
		
		render :layout=>false
	end

	# remove_from_bank
	# Remove the extraction form template from the form bank. Unassign the form template
	# from the original extraction form that was used as the template form.
	def remove_from_bank
		@template = ExtractionFormTemplate.find(params[:bank_id])
		@template.remove_from_bank
		if params[:called_from] == "extraction_form"
			@extraction_form = ExtractionForm.find(params[:ef_id])
			@table_container = "bank_submission_form_div"
	  	@table_partial = "extraction_forms/bank_submission_form"
		elsif params[:called_from] == "bank"
			@to_destroy = "##{params[:item_removed]}"
		end
		render "shared/saved"
	end

	# show_bank_modal
	# When a user is adding new extraction forms to a project, they may choose to add one 
	# from the extraction form bank. If they select this option, give them a pop-up modal window
	# with the list of templates they can add.
	def show_bank_modal
		begin
			@project = Project.find(params[:project_id])
			collaborator_ids =  User.get_collaborator_ids(current_user.id)
			@my_forms = ExtractionFormTemplate.get_user_forms(current_user.id)
			@collab_forms = ExtractionFormTemplate.get_collaborator_forms(current_user.id, collaborator_ids)
			@world_forms = ExtractionFormTemplate.get_world_forms(current_user.id, collaborator_ids)
			@page_title = "The Extraction Form Bank"
		rescue Exception => e
			puts "ERROR: #{e.message}"
		end
	end
	# project_setup_form
	# When a user selects a template to add to their project, show a form with key question assignment and 
	# allow them to rename their new extraction form. 
	def project_setup_form
		project_id = params[:project_id]
		@project = Project.find(project_id)
		@template_id = params[:bank_id]

		# get information about the key questions in the project
		@key_questions = KeyQuestion.where(:project_id=>project_id).all
		available_question_info = ExtractionForm.get_available_questions(project_id,nil)
		@available_questions = available_question_info[0]
		@assigned_questions = available_question_info[1]	
		@no_more_extraction_forms = @project.all_key_questions_accounted_for

		# in the view, change the modal html to be a form to update the title and assign 
		# key questions to the form after it is copied over.
	end

	# assign_to_project
	# After a user selects key questions and a name for the new extraction form, copy it, assign key questions
	# and save it, returning the user to the extraction forms screen.
	def assign_to_project
		@project = Project.find(params[:project_id])
		kqs = params[:kqs]
		kqids = kqs.values
		@template = ExtractionFormTemplate.find(params[:template_id])
		new_title = params[:new_form_title]
		unless kqids.nil? || @project.nil? || new_title.empty? 
			# make an extraction form with all the same attributes as the template form
			new_ef = @template.assign_to_project(@project.id, new_title, current_user.id)

			# assign the key questions to the new extraction form
			new_ef.assign_key_questions(kqids)

			# close the modal and reload the extraction form list
			@key_questions = KeyQuestion.where(:project_id => @project.id).all	
			@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
			@no_more_extraction_forms = @project.all_key_questions_accounted_for	
			@key_questions_assigned = Hash.new

	    # determine if there are templates available
	    @templates_available = ExtractionFormTemplate.templates_available?(current_user)
	    
			# get the key questions associated with each form
			unless @extraction_forms.empty?
				efids = @extraction_forms.collect{|record| record.id}
				efids.uniq!
				efids.each do |eid|
					kqs = ExtractionForm.get_assigned_question_numbers(eid)
					@key_questions_assigned[eid] = kqs.join(", ")	
				end
			end
			@table_container = 'ef_form_list_div'
			@table_partial = 'projects/ef_form_list_explanation'
			@destroy_window = "modal_div"
		end
		render "shared/saved"
	end
end