# this controller handles baseline characteristic questions, created in an extraction form.
# Some functions of baseline characteristic are handled in the question_builder_controller. 
# Some listed here are for "custom" creation i.e. creating a question during study data entry (which is no longer supported). 
class BaselineCharacteristicsController < ApplicationController

  # create a new baseline characteristic category, which
  # has many baseline characteristic fields.
  # renders shared/replace_partial.js.erb
  def new
    @baseline_characteristic = BaselineCharacteristic.new
        @editing=false
        @extraction_form = ExtractionForm.find(params[:extraction_form_id])
        if !params[:study_id].nil? && params[:study_id] != ""
            @study = Study.find(params[:study_id])
        end
  end

  # edit baseline characteristic category
  # renders shared/render_partial_and_modal.js.erb
  def edit
    @baseline_characteristic = BaselineCharacteristic.find(params[:id])
        @question = BaselineCharacteristic.find(@baseline_characteristic.id)
        @fields = @question.get_fields  
        @extraction_form = ExtractionForm.find(@baseline_characteristic.extraction_form_id)
    @editing = true 
  end

  # create new baseline characteristic category
  def create
    @baseline_characteristic = BaselineCharacteristic.new(params[:baseline_characteristic])
    puts "-------------\nCreated a new baseline characteristic. The Question is: #{@baseline_characteristic.question}\n\n"
    @baseline_characteristic.question_number = ExtractionForm.get_next_question_number('BaselineCharacteristic',@baseline_characteristic.extraction_form_id)
    puts "The question number is #{@baseline_characteristic.question_number}\n\n"
        @extraction_form = ExtractionForm.find(@baseline_characteristic.extraction_form_id)
    if @saved = @baseline_characteristic.save
        puts "The baseline characteristic was supposedly saved.\n\n"
        unless params[:baseline_characteristic_choices].nil? || @extraction_form.id.nil?
            BaselineCharacteristicField.save_question_choices(params[:baseline_characteristic_choices], @baseline_characteristic.id, false,params[:subquestion_text],params[:gets_sub],params[:has_subquestion])    
        end
            @questions = BaselineCharacteristic.where(:extraction_form_id => @extraction_form.id).all.sort_by{|q| q.question_number}
            @model="baseline_characteristic"
            @baseline_characteristic = BaselineCharacteristic.new       
    else
            puts "It was not saved."
            problem_html = create_error_message_html(@baseline_characteristic.errors)
            flash[:modal_error] = problem_html
    end
    #render 'question_builder/create'
  end

  # update existing baseline characteristic category
  def update
    @baseline_characteristic = BaselineCharacteristic.find(params[:id])
        @extraction_form = ExtractionForm.find(@baseline_characteristic.extraction_form_id) 
    if @saved = @baseline_characteristic.update_attributes(params[:baseline_characteristic])    

            unless @baseline_characteristic.field_type == "text"
                BaselineCharacteristicField.save_question_choices(params[:baseline_characteristic_choices], @baseline_characteristic.id,true,params[:subquestion_text],params[:gets_sub],params[:has_subquestion_baseline_characteristic])
            else
                @baseline_characteristic.remove_fields
            end
            @model="baseline_characteristic"
            @question = BaselineCharacteristic.find(@baseline_characteristic.id)
            @questions = BaselineCharacteristic.where(:extraction_form_id=>@extraction_form.id).order("question_number ASC")

        else
            problem_html = create_error_message_html(@baseline_characteristic.errors)
            flash[:modal_error] = problem_html  
    end
  end

    # delete baseline characteristic category.
    # handles custom (study) only - no longer being used. 
    # delete a baseline characteristic is handled in the question_builder_controller.
    # renders shared/saved.js.erb
    # @deprecated
  def destroy
    @baseline_characteristic = BaselineCharacteristic.find(params[:id])
        @baseline_characteristic.destroy
        @study = Study.find(@baseline_characteristic.study_id)
        @extraction_form = ExtractionForm.find(@baseline_characteristic.extraction_form_id)
        @arms = Arm.where(:study_id => @study.id)
        @extraction_form = ExtractionForm.find(@extraction_form.id)
        @baseline_characteristic = BaselineCharacteristic.new
        @baseline_characteristic_extraction_form_fields = BaselineCharacteristic.where(:extraction_form_id=>@extraction_form.id)
        @table_container = "baseline_characteristic_fields_table"
        @table_partial = "baseline_characteristic_data_points/table"
        render "shared/saved.js.erb"
  end
end
