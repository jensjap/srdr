# @deprecated
# (?)
# possibly not being used - this controller was used to create individual columns in the outcomes section of an extraction form.
# This may not apply to the new section.
class OutcomeColumnsController < ApplicationController
  before_filter :require_user
	# new
	# create a new outcome column  
  def new
    @outcome_column = OutcomeColumn.new
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])	
	@project = Project.find(@extraction_form.project_id)
	@div_name = "new_col_entry"
	@partial_name = "outcome_columns/form"
	render "shared/render_partial.js.erb"
  end
 
	# create
	# save a new outcome column
  def create
    @outcome_column = OutcomeColumn.new(params[:outcome_column])
	@extraction_form = ExtractionForm.find(@outcome_column.extraction_form_id)	
	@project = Project.find(@extraction_form.project_id)	
    if @outcome_column.column_header == ""
		@outcome_column.column_header = nil
	end
	if @saved = @outcome_column.save
		if @outcome_column.outcome_type == "Categorical"
			@message_div = "saved_item_indicator"
			@extraction_form_categorical_columns = OutcomeColumn.where(:extraction_form_id => @outcome_column.extraction_form_id, :outcome_type => "Categorical").all
		else
			@message_div = "saved_item_indicator_2"
			@extraction_form_continuous_columns = OutcomeColumn.where(:extraction_form_id => @outcome_column.extraction_form_id, :outcome_type => "Continuous").all	
		end
		type = @outcome_column.outcome_type.downcase
		@table_container = "#{type}_outcome_data_fields_table"
		@table_partial = "outcome_columns/#{type}_table"
		@entry_container = "#{type}_outcome_data_fields_entry"
		@entry_partial = "outcome_columns/#{type}_extraction_form_form"
		@modal = true
		@outcome_column = OutcomeColumn.new
	else
		problem_html = create_error_message_html(@outcome_column.errors)
		flash[:modal_error] = problem_html
		if (@outcome_column.outcome_type == "Continuous")
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
	@column = OutcomeColumn.where(:id => params[:outcome_column_id]).first
	@type = @column.outcome_type
	@project = Project.find(params[:project_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@column.destroy
	@extraction_form_categorical_columns = OutcomeColumn.where(:extraction_form_id => params[:extraction_form_id], :study_id => nil, :outcome_type => "Categorical").all
	@extraction_form_continuous_columns = OutcomeColumn.where(:extraction_form_id => params[:extraction_form_id], :study_id => nil, :outcome_type => "Continuous").all	
end

end
