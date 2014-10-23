# this controller handles design detail questions, created in an extraction form.
# Some functions of design details are handled in the question_builder_controller. 
# Some listed here are for "custom" creation i.e. creating a question during study data entry (which is no longer supported). 
class DesignDetailsController < ApplicationController

    # create new design detail category.
    # renders shared/render_partial.js.erb
  def new
    @design_detail = DesignDetail.new
    @extraction_form = ExtractionForm.find(params[:extraction_form_id])
    if !params[:study_id].nil? && params[:study_id] != ""
        @study = Study.find(params[:study_id])
    end
    @editing=false
  end

    # edit existing design detail category.
    # renders shared/render_partial_and_modal.js.erb
  def edit
    @design_detail = DesignDetail.find(params[:id])
    @question = DesignDetail.find(@design_detail.id)
    @fields = @question.get_fields
    @extraction_form = ExtractionForm.find(@design_detail.extraction_form_id)
    @editing=true
  end

    # save new design detail category.
    # handles question_builder (extraction form) categories.
    # renders shared/saved.js.erb
  def create
    @design_detail = DesignDetail.new(params[:design_detail])
    @design_detail.question_number = ExtractionForm.get_next_question_number("DesignDetail",@design_detail.extraction_form_id)
    @extraction_form = ExtractionForm.find(@design_detail.extraction_form_id)
    if @saved = @design_detail.save
        unless params[:subquestion_text.nil?]

        end
        unless params[:design_detail_choices].nil? || @extraction_form.nil?
            DesignDetailField.save_question_choices(params[:design_detail_choices], @design_detail.id, false, params[:subquestion_text], params[:gets_sub],params[:has_subquestion])
        end
            @design_detail = DesignDetail.new
            @questions = DesignDetail.where(:extraction_form_id => @extraction_form.id).order("question_number ASC")
            @model="design_detail"
    else
        problem_html = create_error_message_html(@design_detail.errors)
        flash[:modal_error] = problem_html
    end
  end

    # update existing design detail category.
    # handles question_builder (extraction form) categories.
    # renders shared/saved.js.erb
  def update
    @design_detail = DesignDetail.find(params[:id])
        @extraction_form = ExtractionForm.find(@design_detail.extraction_form_id)   
        if @saved = @design_detail.update_attributes(params[:design_detail])
            unless @design_detail.field_type == "text"
                DesignDetailField.save_question_choices(params[:design_detail_choices], @design_detail.id, true,params[:subquestion_text], params[:gets_sub],params[:has_subquestion_design_detail])
            else
                @design_detail.remove_fields
            end
            @model = params[:page_name]
            @question = DesignDetail.find(@design_detail.id)
            @questions = DesignDetail.where(:extraction_form_id=>@extraction_form.id).order("question_number ASC")

        else
            problem_html = create_error_message_html(@design_detail.errors)
            flash[:modal_error] = problem_html
        end
    end


    # destroy existing design detail category.
    # handles custom (study) only.
    # no longer used.
    # @deprecated
  def destroy
    @design_detail = DesignDetail.find(params[:id])
    @extraction_form = ExtractionForm.find(@design_detail.extraction_form_id)
    @design_detail.destroy
    @questions = DesignDetail.where(:extraction_form_id => @extraction_form.id).order("question_number ASC")
    @study = Study.find(@design_detail.study_id)
    @design_detail = DesignDetail.new
    @message_div = "removed_item_indicator_dd"
    render "shared/saved.js.erb"
  end
end
