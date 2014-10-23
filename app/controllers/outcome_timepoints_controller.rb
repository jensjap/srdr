class OutcomeTimepointsController < ApplicationController
  before_filter :require_user

  def new
      @outcome_timepoint = OutcomeTimepoint.new
	  @outcome_timepoint.save
	  @study = Study.find(params[:study_id])
  end
  
   	# create
	# save a new outcome timepoint
  def create
    @outcome_timepoint = OutcomeTimepoint.new(params[:outcome_timepoint])
	@outcome_timepoint.save
  end

   	# update
	# update an existing outcome timepoint
  def update
    @outcome_timepoint = OutcomeTimepoint.find(params[:id])
	@outcome_timepoint.update_attributes(params[:outcome_timepoint])
  end

   	# destroy
	# delete an existing outcome timepoint
  def destroy
  end

  def edit
	@timepoint = OutcomeTimepoint.find(params[:tp_id])
	@outcome = Outcome.find(@timepoint.outcome_id)
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
  end
  
  def cancel
	@timepoint = OutcomeTimepoint.find(params[:tp_id])  
	@outcome = Outcome.find(@timepoint.outcome_id)
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all  
  end
  
  def save
	@timepoint = OutcomeTimepoint.find(params[:outcome_timepoint_id])
	@timepoint.number = params[:tp_num]
	@timepoint.time_unit = params[:tp_unit]
	@timepoint.save
	@outcome = Outcome.find(@timepoint.outcome_id)
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all    
  end
  
  def destroy_modal
	@timepoint = OutcomeTimepoint.find(params[:tp_id])
	@timepoint.destroy
	@outcome = Outcome.find(@timepoint.outcome_id)
	@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
	@study = Study.find(@outcome.study_id)
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all      
  end
  
  
  
  end
