# This controller handles creation and destruction of columns for the adverse events table (in an extraction form).
class AdverseEventColumnsController < ApplicationController

    # Open a new dialog window to create a new adverse event column.
    # Uses views/adverse_event_columns/new.js.erb.
    def new
        @adverse_event_column = AdverseEventColumn.new
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        @project = Project.find(params[:project_id])
    end

    # save the new adverse event column.
    # uses views/adverse_event_columns/create.js.erb
    def create
        @adverse_event_column = AdverseEventColumn.new(params[:adverse_event_column])
        if @saved = @adverse_event_column.save
            @extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => @adverse_event_column.extraction_form_id).all
            @extraction_form = ExtractionForm.find(@adverse_event_column.extraction_form_id)
            @project = Project.find(@extraction_form.project_id)
        else
            problem_html = create_error_message_html(@adverse_event_column.errors)
            flash[:modal_error] = problem_html
        end
    end

    # destroy the adverse event column.
    # uses views/adverse_event_columns/destroy.js.erb
    def destroy
        @adverse_event_column = AdverseEventColumn.find(params[:id])
        @extraction_form = ExtractionForm.find(@adverse_event_column.extraction_form_id)
        @project = Project.find(@extraction_form.project_id)
        @has_study_data = AdverseEventColumn.has_study_data(@adverse_event_column.id)
    end

end
