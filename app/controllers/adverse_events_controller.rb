# This controller handles the creation and destruction of adverse events in a study. 
# These are the rows in the adverse_event_table in the adverse event section of study data entry.
class AdverseEventsController < ApplicationController
  before_filter :require_user
  
  # create the new adverse event row
  def create
  	@study = Study.find(params[:study_id])
	@project = Project.find(@study.project_id)
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@adverse_event = AdverseEvent.new
	@adverse_event.study_id = @study.id
	@adverse_event.extraction_form_id = @extraction_form.id
	@saved = @adverse_event.save

	if @saved
		@extraction_form = ExtractionForm.find(@adverse_event.extraction_form_id)
		@extraction_form_adverse_event_columns = AdverseEventColumn.find(:all, :conditions => ["extraction_form_id = ?", @extraction_form.id])
		@arms = Arm.find(:all, :conditions => ["study_id = ? AND extraction_form_id = ?", params[:study_id], @extraction_form.id], :order => "display_number ASC")
		@adverse_events = AdverseEvent.find(:all, :conditions=>['study_id=? AND extraction_form_id = ?', params[:study_id], @extraction_form.id])
		@adverse_event_result = AdverseEventResult.new
		@num_rows = 0

		# get titles suggested by the extraction form creator
		@suggested_ae_titles = ExtractionFormAdverseEvent.where(:extraction_form_id => params[:extraction_form_id])
		if @extraction_form.adverse_event_display_arms
			@num_rows = @num_rows + @arms.length
		end
		if @extraction_form.adverse_event_display_total
			@num_rows = @num_rows + 1
		end		
	else
		problem_html = create_error_message_html(@adverse_event.errors)
		flash[:modal_error] = problem_html
	end	
  end

  # delete the adverse event row
  def destroy
    @adverse_event = AdverseEvent.find(params[:id])
	@study = Study.find(@adverse_event.study_id)
	@project = Project.find(@study.project_id)
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])	
	@adverse_event_results = AdverseEventResult.where(:adverse_event_id => @adverse_event.id).all
	@adverse_event_results.each do |item|
		item.destroy
	end	
	# get titles suggested by the extraction form creator
	@suggested_ae_titles = ExtractionFormAdverseEvent.where(:extraction_form_id => params[:extraction_form_id])
    @adverse_event.destroy
	@extraction_form_adverse_event_columns = AdverseEventColumn.find(:all, :conditions => ["extraction_form_id = ?", @extraction_form.id])
	@arms = Arm.find(:all, :conditions => ["study_id = ? AND extraction_form_id = ?", @study.id, @extraction_form.id], :order => "display_number ASC")
	@adverse_events = AdverseEvent.find(:all, :conditions=>['study_id=? AND extraction_form_id = ?', @study.id, @extraction_form.id])
	@num_rows = 0
	if @extraction_form.adverse_event_display_arms
		@num_rows = @num_rows + @arms.length
	end
	if @extraction_form.adverse_event_display_total
		@num_rows = @num_rows + 1
	end			
	@adverse_event_result = AdverseEventResult.new
  end

 
  end
