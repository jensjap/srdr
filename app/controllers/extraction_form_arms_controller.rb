# this controller handles creation and editing of arm suggestions - when a contributor adds arm names to the extraction form.
class ExtractionFormArmsController < ApplicationController
  	before_filter :require_user
	respond_to :js, :html
  
  # create a new arm
  def new
  	@editing = false
    @extraction_form_arm = ExtractionFormArm.new
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@project = Project.find(params[:project_id])
    puts ".............. >>> extraction_form_armms_controller::new "
    @extraction_form_arm_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ARMS", "GENERAL"])
  end

  def new_instr
  	@editing = false
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@project = Project.find(params[:project_id])
	@section = params[:section]
	@data_element = params[:data_element]
    @extraction_form_arm_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ARMS", "GENERAL"])
    if @extraction_form_arm_instr.nil?
        @extraction_form_arm_instr = EfInstruction.new
    end
  end

  # edit the arm with id = params[:id].
  # renders edit.js.erb
  def edit
    puts ".............. >>> extraction_form_armms_controller::edit "
    @extraction_form_arm = ExtractionFormArm.find(params[:id])
	@extraction_form = ExtractionForm.find(@extraction_form_arm.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
  	@efid = @extraction_form_arm.extraction_form_id
    @editing = true
  end

  # save the new arm. 
  # renders shared/saved.js.erb
  def create
    puts ".............. >>> extraction_form_armms_controller::create "
    @extraction_form_arm = ExtractionFormArm.new(params[:extraction_form_arm])
	@extraction_form = ExtractionForm.find(@extraction_form_arm.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
	@error_div = "validation_message_arms"	
	if (@saved = @extraction_form_arm.save)
		@arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form_arm.extraction_form_id)
		@efid = @extraction_form_arm.extraction_form_id
		@extraction_form_arm = ExtractionFormArm.new
		@message_div = "saved_indicator_arms"
		@table_container = "arms_table"
		@table_partial = "extraction_form_arms/table"
		@entry_container = "new_arm_entry"
		@entry_partial = "extraction_form_arms/form"
		@close_window = "new_arm_entry"
	else
		problem_html = create_error_message_html(@extraction_form_arm.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
	end
	render "shared/saved.js.erb"
  end

  # update/save the edits to arm with id = params[:id].
  # renders shared/saved.js.erb
  def update
    puts ".............. >>> extraction_form_armms_controller::update "
    @arm = ExtractionFormArm.find(params[:id])
    previous_arm_name = @arm.name
	@extraction_form = ExtractionForm.find(@arm.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
	@error_div = "validation_message_arms"		
	if (@saved = @arm.update_attributes(params[:extraction_form_arm]))
		@arm.update_studies(previous_arm_name)
		@arms = ExtractionFormArm.where(:extraction_form_id => @arm.extraction_form_id)
		@efid = @arm.extraction_form_id
		@extraction_form_arm = ExtractionFormArm.new
		@message_div = "saved_indicator_arms"
		@table_container = "arms_table"
		@table_partial = "extraction_form_arms/table"
		@entry_container = "new_arm_entry"
		@entry_partial = "extraction_form_arms/form"			
		@close_window = "new_arm_entry"
	else
		problem_html = create_error_message_html(@arm.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
    end
	render "shared/saved.js.erb"	
  end

  # delete the arm. 
  # renders shared/saved.js.erb
  def destroy
    @arm = ExtractionFormArm.find(params[:id])
	@extraction_form = ExtractionForm.find(@arm.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)	
    efid = @arm.extraction_form_id
	@arm.destroy
	@arms = ExtractionFormArm.where(:extraction_form_id => efid)
    @extraction_form_arm = ExtractionFormArm.new
    @table_container = "arms_table"
	@message_div = "removed_indicator_arms"
	@table_partial = "extraction_form_arms/table"
	@entry_container = "new_arm_entry"
	@entry_partial = "extraction_form_arms/form"
	render "shared/saved.js.erb"	
  end

end