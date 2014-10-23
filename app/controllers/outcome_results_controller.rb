class OutcomeResultsController < ApplicationController
  before_filter :require_user
  
	# new
	# create a new outcome result (data point)  
  #def new
   # @outcome_result = OutcomeResult.new
  #end

	# edit
	# edit an existing outcome result (data point)  
  #def edit
  #  @outcome_result = OutcomeResult.find(params[:id])
  #end 
 
	# create
	# create a new outcome result (data point)
  def create
    # save any footnotes associated with the data.
    # see application controller for this method
	footnotes = get_footnotes_from_params(params)
	Footnote.remove_entries(params[:study_id],"results")
	FootnoteField.remove_entries(params[:study_id],"results")
	unless footnotes.empty?
	  	footnotes.each do |fnote|
	  		mynote = Footnote.new(fnote)
	  		mynote.save
		end
	end    
  	OutcomeResult.save_data_points(params, params[:study_id])
	@message_div = "saved_item_indicator"
	render 'shared/saved.js.erb'
  end

 	# delete
	# delete an existing outcome result (data point)
  def destroy
    @outcome_result = OutcomeResult.find(params[:id])
    @outcome_result.destroy
  end
  
 	# clear_table
	# delete all data points from the table
  def clear_table
	OutcomeResult.clear_table(params)
	extraction_form_id = params[:extraction_form_id]
	@study = Study.find(params[:study_id])
	@study_arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => extraction_form_id).all
	
	@categorical_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Categorical", :extraction_form_id => extraction_form_id).all
	@continuous_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Continuous", :extraction_form_id => extraction_form_id).all

	# GATHER TEMPLATE COLUMNS
	@extraction_form_categorical_columns = OutcomeColumn.where(:extraction_form_id => extraction_form_id, :outcome_type => "Categorical").all
	@extraction_form_continuous_columns = OutcomeColumn.where(:extraction_form_id => extraction_form_id, :outcome_type => "Continuous").all
	
	# GATHER OUTCOMES
	@continuous_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Continuous", :extraction_form_id => extraction_form_id).all	
	@categorical_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Categorical", :extraction_form_id => extraction_form_id).all
	
	# GATHER TIMEPOINTS
	@continuous_timepoints = Outcome.get_timepoints_for_outcomes_array(@continuous_outcomes);	
	@categorical_timepoints = Outcome.get_timepoints_for_outcomes_array(@categorical_outcomes);				
	@outcome_data_points = OutcomeResult.new
	@cat_field_ids = Footnote.get_cat_field_ids(@study.id, @extraction_form_categorical_columns, @categorical_outcomes, @categorical_timepoints, extraction_form_id)
	@cont_field_ids = Footnote.get_cont_field_ids(@study.id, @extraction_form_continuous_columns, @continuous_outcomes, @continuous_timepoints, extraction_form_id)	
	
	# gather any footnotes for the first selections
	@cat_footnotes = Footnote.where(:study_id=>@study.id, :page_name=>"results",:data_type=>"categorical").order("note_number ASC")
	@cont_footnotes = Footnote.where(:study_id=>@study.id,:page_name=>"results",:data_type=>"continuous").order("note_number ASC")
	@div_name = "outcome_results_table"
	@partial_name = "outcome_results/table"
	render "shared/render_partial.js.erb"
 end
 
end
