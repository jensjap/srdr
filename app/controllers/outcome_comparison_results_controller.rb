# @deprecated
# (?)
# possibly not being used - this controller was used to create individual data points in the first version of the outcome comparisons study data setup.
# This may not apply to the new section.
class OutcomeComparisonResultsController < ApplicationController

	# save a new outcome comparison result (data point)
  def create
    OutcomeComparisonResult.save_data_points(params, session[:study_id])
	@message_div = "saved_item_indicator"
    render 'shared/saved.js.erb'
  end

	# delete an existing outcome comparison result (data point)
  def destroy
    @outcome_comparison = OutcomeComparisonResult.find(params[:id])
    @outcome_comparison.destroy
  end
  
	# clear the outcome comparison results data table - delete all data points 
  def clear_table
	OutcomeComparisonResult.clear_table(params)
	extraction_form_id = params[:extraction_form_id]
	@study = Study.find(params[:study_id])
	@study_arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => extraction_form_id).all

	@categorical_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Categorical", :extraction_form_id => extraction_form_id).all
	@continuous_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Continuous", :extraction_form_id => extraction_form_id).all
	
	@extraction_form_categorical_columns = OutcomeComparisonColumn.where(:extraction_form_id => extraction_form_id, :outcome_type => "Categorical").all
	@extraction_form_continuous_columns = OutcomeComparisonColumn.where(:extraction_form_id => extraction_form_id, :outcome_type => "Continuous").all
	@outcome_comparison_results = OutcomeComparisonResult.new

	@div_name = "outcome_comparison_results_table"
	@partial_name = "outcome_comparison_results/table"
	render "shared/render_partial.js.erb"

 end
  
end
