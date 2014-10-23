# this controller handles creation, editing, updating, moving-up-in-a-list and deletion of arms in study data entry.
class ArmsController < ApplicationController
  	before_filter :require_user
  
  # create a new arm
  def new
	@editing = false
    @arm = Arm.new
	@arm_options = Arm.get_dropdown_options_for_new_arm(params[:extraction_form_id], params[:study_id])
  end

  # edit the arm with id = params[:id]
  def edit
		@editing = true  
    	@arm = Arm.find(params[:id])
		@arm_options = Arm.get_dropdown_options_for_new_arm(params[:extraction_form_id], params[:study_id])
  end

  # save the new arm
  def create
		unless params[:arm][:title] == "Choose a suggested arm..."
			@editing = false  
			@arm = Arm.new(params[:arm])
			@arm.study_id = params[:study_id]
			display_num = @arm.get_display_number(params[:study_id], params[:extraction_form_id])
			@arm.display_number = display_num
			@arm.extraction_form_id = params[:extraction_form_id]
			@extraction_form = ExtractionForm.find(@arm.extraction_form_id)
			if @saved = @arm.save 
				@arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => params[:extraction_form_id]).order("display_number ASC")
				@arm = Arm.new			
				#@study = Study.find(params[:study_id])
				#@project = Project.find(@study.project_id)
				#@study_extforms = StudyExtractionForm.where(:study_id=>@study.id)			
				# get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
				# sections in each form, sections borrowed from other forms, key questions associated with 
				# each section, etc.
				#unless @study_extforms.empty?
				#	@extraction_forms,@arm_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Arm.get_extraction_form_information(@study_extforms,@study,@study.project_id)
				#end
			else
			   problem_html = create_error_message_html(@arm.errors)
				flash[:modal_error] = problem_html
			end
  	else
  		flash[:modal_error] = "Please choose one of the suggested arm names or create a new one by selecting \"Other\""
  	end
  end

  # update/save the edits to arm with id = params[:id]
  def update
		@editing = false  
    @arm = Arm.find(params[:id])
		if @saved = @arm.update_attributes(params[:arm])
      @arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => params[:extraction_form_id]).order("display_number ASC")
        
			@extraction_form = ExtractionForm.find(params[:extraction_form_id])
			if @extraction_form.adverse_event_display_arms == true
				#@arm_col = AdverseEventColumn.where(:arm_id => @arm.id).first
				#@arm_col.name = @arm.title
				#@arm_col.description = "Arm Info for " + @arm.title
				#@arm_col.save
			end		
		
			@arm = Arm.new
		
			# used to capture suggested arm names from extraction forms
			extraction_form_arms = Array.new
			@descriptions = Hash.new
			@study = Study.find(params[:study_id])
			@project = Project.find(@study.project_id)
			@study_extforms = StudyExtractionForm.where(:study_id=>@study.id)
					
			# get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
			# sections in each form, sections borrowed from other forms, key questions associated with 
			# each section, etc.
			unless @study_extforms.empty?
		    @extraction_forms,@arm_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Arm.get_extraction_form_information(@study_extforms,@study,@study.project_id)
			end
    		@message_div = "saved_item_indicator"
	        @table_container = "arms_table"
	        @table_partial = "arms/table"
	        @entry_container = "new_arm_entry"
	        @entry_partial = "arms/form"
			@modal = "entry_form"	
   		else
      		problem_html = create_error_message_html(@arm.errors)
			flash[:modal_error] = problem_html
			@error_div = "validation_message"
			@error_partial = "layouts/modal_info_messages"
    	end
		render "arms/create.js.erb"
    end

    # delete the arm
    def destroy
		begin
			@editing = false  
		    @arm = Arm.find(params[:id])
		    @project = Project.find(params[:project_id])
			@arm.shift_display_numbers(params[:study_id], @arm.extraction_form_id)	
			has_data, data_locations = @arm.has_data?
		    unless has_data
				@extraction_form = ExtractionForm.find(@arm.extraction_form_id)
				#@arm_col = AdverseEventColumn.where(:arm_id => @arm.id).all
				@arm_col = AdverseEventResult.where(:arm_id=>@arm.id)
				@arm_col.each do |armcol|
					armcol.destroy
				end	
				@arm.destroy
				@arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => params[:extraction_form_id]).order("display_number ASC")
				@arm = Arm.new
				@div_name = "arms_table"
				@partial_name = "arms/table"
				@msg_type = "success"
				@msg_title = "The Arm was successfully deleted."
				render "shared/render_partial.js.erb"
			else
				@msg_title = "#{@arm.title} has associated data."
				@msg_description = "Data related to this arm may be found in the following sections in this study: #{data_locations.join(", ")}. Please review and remove data associated with this arm before continuing with deletion."
				@msg_type = "error"
				#flash[:error_message] = "You must remove all results and comparisons associated with this arm before it can be deleted"
				#@div_name = "info_messages"
				#@partial_name = "layouts/info_messages"
				render "shared/show_message.js.erb"
			end	
			#render "shared/render_partial.js.erb"
		rescue Exception=>e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
  	end

  # move the arm up in the list 
  # (increase its display number by 1, and decrease the other arm's display number)
  def moveup
	@editing = false  
    @arm = Arm.find(params[:arm_id])
	Arm.move_up_this(params[:arm_id], params[:study_id], params[:extraction_form_id])
	@arms = Arm.find(:all, :conditions => {:study_id => params[:study_id], :extraction_form_id => params[:extraction_form_id]}).sort_by{|arm| arm.display_number}
	@arm = Arm.new
	@div_name = "arms_table"
	@partial_name = "arms/table"	
	render "shared/render_partial.js.erb"	
  end  
  
  end
