class OutcomeMeasuresController < ApplicationController
	respond_to :js
	def create
		@outcome_measure = OutcomeMeasure.new(params[:outcome_measure])
		render "create.js.erb"
	end
	
	def update
		
		@outcome_measure = OutcomeMeasure.find(params[:id])
		@outcome = Outcome.find(@outcome_measure.outcome_id)
		@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
		@study = Study.find(@outcome.study_id)
		@arms = Arm.where(:study_id => @study.id).all
		
		if @saved = @outcome_measure.update_attributes(params[:outcome_measure])
			if @outcome.outcome_type == "Continuous"
				@partial = "outcome_data_points/continuous_table"
			else
				@partial = "outcome_data_points/categorical_table"
			end
			@modal = "entry_form"		
		else
			problem_html = create_error_message_html(@outcome_measure.errors)
			flash[:modal_error] = problem_html
			@error_partial = "layouts/modal_info_messages"		
		end
		@outcome_timepoints =params[:outcome_timepoints_list]
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@outcome_tp_arr = @outcome_timepoints.split("_")
		@outcome_timepoints = OutcomeTimepoint.find_all_by_id(@outcome_tp_arr)
		@outcome_measure = OutcomeMeasure.new
		@error_div = "validation_message"
		@outcome_data_point = OutcomeDataPoint.new
		render "create.js.erb"
	end	

	def edit
		@measure = OutcomeMeasure.find(params[:measure_id])
		@outcome_measure = OutcomeMeasure.find(params[:measure_id])
		@outcome = Outcome.find(@measure.outcome_id)
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		render "outcome_measures/edit.js.erb"		
	end
	
	def destroy
		@outcome_measure = OutcomeMeasure.find(params[:id])
		@outcome = Outcome.find(@outcome_measure.outcome_id)
		@measure = @outcome_measure
		@outcome_measure.destroy
		@outcome_measure = OutcomeMeasure.new
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@study = Study.find(@outcome.study_id)
		@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
		@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
		@arms = Arm.where(:study_id => @study.id, :extraction_form_id => @extraction_form.id).all
		@outcome_data_point = OutcomeDataPoint.new
		render "outcome_measures/destroy.js.erb"
	end
	
	def save
		@outcome_measure = OutcomeMeasure.find(params[:outcome_measure_id])
		@outcome_measure.measure_name = params[:outcome_measure]["measure_name"]
		@outcome_measure.unit = params[:outcome_measure]["unit"]
		@outcome_measure.save
		@measure = @outcome_measure
		@outcome = Outcome.find(@outcome_measure.outcome_id)
		@outcome_measure = OutcomeMeasure.new
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
		@study = Study.find(@outcome.study_id)
		@arms = Arm.where(:study_id => @study.id, :extraction_form_id => @extraction_form.id).all
		@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
		@outcome_data_point = OutcomeDataPoint.new	
	end
	
	def cancel
		@outcome_measure = OutcomeMeasure.find(params[:measure_id])
		@measure = @outcome_measure
		@outcome = Outcome.find(@outcome_measure.outcome_id)
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all	
		render "outcome_measures/cancel.js.erb"		
	end
	
	def update_measure_window
		@outcome = Outcome.find(params[:outcome_id])
		@outcome_measure = OutcomeMeasure.new
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
	end
	
end
