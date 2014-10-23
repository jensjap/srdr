# this controller handles creation and editing of adverse event suggestions - when a contributor adds adverse event names to the extraction form.
class ExtractionFormAdverseEventsController < ApplicationController
  	before_filter :require_user
	respond_to :js, :html
  
  # create a new adverse event
  def new
  	@editing = false
    @extraction_form_adverse_event= ExtractionFormAdverseEvent.new
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@project = Project.find(params[:project_id])
  end
  # edit the adverse event with id = params[:id].
  # renders edit.js.erb
  def edit
    @extraction_form_adverse_event = ExtractionFormAdverseEvent.find(params[:id])
	@extraction_form = ExtractionForm.find(@extraction_form_adverse_event.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
  	@efid = @extraction_form_adverse_event.extraction_form_id
    @editing = true
  end

  # save the new adverse event 
  # renders shared/saved.js.erb
  def create
    @extraction_form_adverse_event = ExtractionFormAdverseEvent.new(params[:extraction_form_adverse_event])
	@extraction_form = ExtractionForm.find(@extraction_form_adverse_event.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
	@error_div = "validation_message_adverse_events"	
	if (@saved = @extraction_form_adverse_event.save)
		@adverse_events = ExtractionFormAdverseEvent.where(:extraction_form_id => @extraction_form_adverse_event.extraction_form_id)
		@efid = @extraction_form_adverse_event.extraction_form_id
		@extraction_form_adverse_event = ExtractionFormAdverseEvent.new
		@message_div = "saved_indicator_ae"
		@table_container = "adverse_events_table"
		@table_partial = "extraction_form_adverse_events/table"
		@entry_container = "new_adverse_event_title_div"
		@entry_partial = "extraction_form_adverse_events/form"
		@close_window = "new_adverse_event_title_div"
	else
		problem_html = create_error_message_html(@extraction_form_adverse_event.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
	end
	render "shared/saved.js.erb"
  end

  # update/save the edits to adverse event with id = params[:id].
  # renders shared/saved.js.erb
  def update
    
    @adverse_event = ExtractionFormAdverseEvent.find(params[:id])
    previous_adverse_event_name = @adverse_event.title
	@extraction_form = ExtractionForm.find(@adverse_event.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
	@error_div = "validation_message_adverse_events"		
	if (@saved = @adverse_event.update_attributes(params[:extraction_form_adverse_event]))
		# IF WE WANT ANY CHANGES TO APPLY TO EXISTING STUDIES...
		#@adverse_event.update_studies(previous_adverse_event_name)
		@adverse_events = ExtractionFormAdverseEvent.where(:extraction_form_id => @adverse_event.extraction_form_id)
		@efid = @adverse_event.extraction_form_id
		@extraction_form_adverse_event = ExtractionFormAdverseEvent.new
		@message_div = "saved_indicator_ae"
		@table_container = "adverse_events_table"
		@table_partial = "extraction_form_adverse_events/table"
		@entry_container = "new_adverse_event_title_div"
		@entry_partial = "extraction_form_adverse_events/form"			
		@close_window = "new_adverse_event_title_div"
	else
		problem_html = create_error_message_html(@adverse_event.errors)
		flash[:modal_error] = problem_html
		@error_partial = 'layouts/modal_info_messages'
    end
	render "shared/saved.js.erb"	
  end

  # delete the adverse_event. 
  # renders shared/saved.js.erb
  def destroy
    @adverse_event = ExtractionFormAdverseEvent.find(params[:id])
	@extraction_form = ExtractionForm.find(@adverse_event.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)	
    efid = @adverse_event.extraction_form_id
	@adverse_event.destroy
	@adverse_events = ExtractionFormAdverseEvent.where(:extraction_form_id => efid)
    @extraction_form_adverse_event = ExtractionFormAdverseEvent.new
    @table_container = "adverse_events_table"
	@message_div = "removed_indicator_ae"
	@table_partial = "extraction_form_adverse_events/table"
	@entry_container = "new_adverse_event_title_div"
	@entry_partial = "extraction_form_adverse_events/form"
	render "shared/saved.js.erb"	
  end

end