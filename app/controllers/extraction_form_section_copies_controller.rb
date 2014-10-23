class ExtractionFormSectionCopiesController < ApplicationController
	  layout :determined_by_request
	# display the previous extraction forms that information can be borrowed from
	def import_from_previous_forms
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		# NEED ONLY TO LIST FORMS THAT I ARE NOT ALREADY BORROWING FROM THE CURRENT??
		@previous_extraction_forms = ExtractionForm.find(:all,:conditions=>["project_id = ? AND id <> ?",params[:project_id], params[:extraction_form_id]])
		
		@assigned_questions_hash, @included_sections_hash,@checked_boxes = [Hash.new,Hash.new,Hash.new]
		# for each of the previously existing forms
		@previous_extraction_forms.each do |ef|
			
			# get the key questions assigned
			@assigned_questions_hash[ef.id] = ExtractionForm.get_assigned_question_numbers(ef.id)
				
			# get the sections included
			@included_sections_hash[ef.id] = ExtractionFormSection.get_included_sections_by_extraction_form_id(ef.id)	
			@borrowers = ExtractionFormSectionCopy.get_borrowers(params[:extraction_form_id])
				
			# determine which boxes should already be checked
			already_entered = ExtractionFormSectionCopy.get_previous_data(params[:extraction_form_id], ef.id)
			already_entered = already_entered.collect{|x| x.section_name}
			@checked_boxes[ef.id] = already_entered
				
			# get rid of key questions and publications
			@included_sections_hash[ef.id].delete_at(0);@included_sections_hash[ef.id].delete_at(0);
			
		end
	end	
	
	# save any import requests made by the user
	def save_import_request
		# set up for arms page:
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@project = Project.find(params[:project_id])
		@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"arms")
		@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"ExtractionFormArm")
	  	@arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id)
	  	@extraction_form_arm = ExtractionFormArm.new
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => @extraction_form.id, :section_name => "arms").first		
		@extraction_form_section = ExtractionFormSection.new
		# collect the params and add the requests to a junction table
		unless params[:import_section].nil?
			input = params[:import_section]
			ExtractionFormSectionCopy.setup_import(@extraction_form.id,input)
		end
		unless params[:import_section].nil?
			flash[:success] = "Import settings were successfully updated."
		else
			flash[:notice] = "No previous information was imported for this form."
		end
	end
	
 protected
 def determined_by_request
   if request.xhr?
     return false
   else
     'application'
   end
 end	
	
end
