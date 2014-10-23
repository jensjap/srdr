class ComparisonDataPointsController < ApplicationController

  # use the comparison data points inputs to save all required data
  def create
  	datapoints = params[:comparison_datapoints] # indexed by comparison ID
  	comparators = params[:comparator]           # indexed by column number
  	comparison_type = params[:comparison_type]  # comparison type
  	comparison_measures = params[:comparison_measures]  # indexed by comparison_id
    Comparison.save_comparison_data(comparators,datapoints,comparison_measures)     
    @selected_timepoint_id = params[:selected_timepoint_id]
  	@outcome_id = params[:outcome_id]
  	@outcome = Outcome.find(@outcome_id)
  	@study_id = params[:study_id]
  	@extraction_form_id = params[:extraction_form_id]
  	@arms = Arm.where(:study_id=>@study_id, :extraction_form_id=>@extraction_form_id)
  	@timepoints = OutcomeDataEntry.get_timepoints_array(params[:selected_timepoint_id], @outcome)
  	# get a hash of comparison data, with timepoint id as the key
  	@comparisons = OutcomeDataEntry.get_comparisons("between",@timepoints,@outcome_id,@study_id,@extraction_form_id)
  	# get the collection of measures with comparison_id as the key
    @measures = OutcomeDataEntry.get_comparison_measures(@comparisons)
  	# saved comparators is a uniqe collection of comparators run for the comparisons
  	# which can be used to create column headings where appropriate
  	@comparators = OutcomeDataEntry.get_comparators(@comparisons) 
  	@all_comparators = OutcomeDataEntry.get_all_comparators_for_comparisons(@comparisons.values)
  	@comparison_datapoints = OutcomeDataEntry.get_datapoints_for_comparisons(@comparisons.values)
  	render 'outcome_data_entries/show_between_arm_comparison_table'
  end
end