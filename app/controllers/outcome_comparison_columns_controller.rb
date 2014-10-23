# @deprecated
# (?)
# possibly not being used - this controller was used to create individual columns in the outcome comparisons section of an extraction form.
# This may not apply to the new section.
class OutcomeComparisonColumnsController < ApplicationController
  before_filter :require_user
  
	# create a new outcome comparison column  
  def new
    @outcome_column = OutcomeComparisonColumn.new
	@div_name = "new_comparison_col_entry"
	@div_partial = "outcome_comparison_columns/form"
	render "shared/render_partial.js.erb"
  end

	# save a new comparison column
  def create
	@project = Project.find(params[:project_id])
    @outcome_comparison_column = OutcomeComparisonColumn.new(params[:outcome_comparison_column])
	@extraction_form = ExtractionForm.find(@outcome_comparison_column.extraction_form_id)	
		if @outcome_comparison_column.column_header == ""
			@outcome_comparison_column.column_header = nil
		end
		if @saved = @outcome_comparison_column.save
			if @outcome_comparison_column.outcome_type == "Categorical"
				@message_div = 'saved_item_indicator'
				@extraction_form_categorical_columns = OutcomeComparisonColumn.where(:extraction_form_id => @outcome_comparison_column.extraction_form_id, :outcome_type => "Categorical").all				
			else
			    @message_div = 'saved_item_indicator_2'
			    @extraction_form_continuous_columns = OutcomeComparisonColumn.where(:extraction_form_id => @outcome_comparison_column.extraction_form_id, :outcome_type => "Continuous").all	
			end
			type = @outcome_comparison_column.outcome_type.downcase
			@table_container = "#{type}_outcome_comparison_results_table"
			@table_partial = "outcome_comparison_columns/#{type}_table"
			@entry_container = "#{type}_outcome_comparison_results_entry"
			@entry_partial = "outcome_comparison_columns/#{type}_extraction_form_form"
			@modal = true
			@outcome_comparison_column = OutcomeComparisonColumn.new
		 else
			problem_html = create_error_message_html(@outcome_comparison_column.errors, "")
			flash[:modal_error] = problem_html
			if (@outcome_comparison_column.outcome_type == "Continuous")
				@error_div = "validation_message_cont"
				@error_partial = "layouts/modal_info_messages"
			else
				@error_div = "validation_message_cat"
				@error_partial = "layouts/modal_info_messages"
			end
		end
	render "shared/saved.js.erb"
  end

  def delete
	@column = OutcomeComparisonColumn.where(:id => params[:outcome_comparison_column_id]).first
	@type = @column.outcome_type.downcase
	@project = Project.find(params[:project_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])  
	@column.destroy
	@extraction_form_categorical_columns = OutcomeComparisonColumn.where(:extraction_form_id => params[:extraction_form_id], :study_id => nil, :outcome_type => "Categorical").all
	@extraction_form_continuous_columns = OutcomeComparisonColumn.where(:extraction_form_id => params[:extraction_form_id], :study_id => nil, :outcome_type => "Continuous").all
  end
  
end
