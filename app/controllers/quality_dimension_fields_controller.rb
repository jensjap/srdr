# This controller handles quality dimension fields. A quality dimension field is a row that is specified in the extraction form.
class QualityDimensionFieldsController < ApplicationController
	respond_to :js, :html

  # create a new quality dimension field (custom field)
  def new
    	@quality_dimension_field = QualityDimensionField.new
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@project = Project.find(@extraction_form.project_id)
    	@editing = false
  end


  # edit an existing quality dimension field (custom field). 
  # renders edit.js.erb
  def edit
  	puts "-----------\nEntered the edit function."
    @quality_dimension_field = QualityDimensionField.find(params[:id])
    puts "Found the field, which is #{@quality_dimension_field.id}\n"
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	puts "Found the form, which is #{@extraction_form.id}\n"
	@project = Project.find(@extraction_form.project_id)
	puts "Found the Project, which is #{@project.id}\n"
	@has_study_data = QualityDimensionField.has_study_data(@quality_dimension_field.id)
	puts "Has study data is #{@has_study_data}\n"
	@editing = true
	puts "Editing is #{@editing}"
  end

  # create a quality dimension field (custom field)
  def create
    qd_params = params[:quality_dimension_field]
    selected_default = qd_params[:selected_default]
    field_notes = qd_params[:field_notes]
    extraction_form_id = qd_params[:extraction_form_id]
    unless selected_default == 'custom'
      QualityDimensionField.generate_legacy_quality_dimensions(extraction_form_id, selected_default)
    else
      title = qd_params[:custom]
      unless title.blank?
        QualityDimensionField.transaction do 
          nextnum = QualityDimensionField.where(:extraction_form_id=>extraction_form_id).maximum(:question_number)
          if nextnum.nil?
            QualityDimensionField.assign_initial_qnums(extraction_form_id)
            nextnum = QualityDimensionField.where(:extraction_form_id=>extraction_form_id).maximum(:question_number)
          end
          # In cases where no quality dimension field exists yet, we need to start the counter
          if nextnum.nil?
            nextnum = 0
          end
          nextnum += 1
          QualityDimensionField.create(:title=>title, :field_notes => field_notes, :question_number => nextnum,:extraction_form_id=>extraction_form_id)
        end
      end    
    end
    @quality_dimension_fields = QualityDimensionField.where(:extraction_form_id=> extraction_form_id).order("question_number ASC")
    @quality_dimension_field = QualityDimensionField.new
    @extraction_form = ExtractionForm.find(extraction_form_id)
    @project = Project.find(@extraction_form.project_id)
  end

  # save changes/update an existing quality dimension field (custom field)
  def update
    @quality_dimension_field = QualityDimensionField.find(params[:id])
    qdparams = params[:quality_dimension_field]
	  @quality_dimension_field.title = qdparams['custom']
    @quality_dimension_field.field_notes = qdparams['field_notes']
    if @saved = @quality_dimension_field.save
		  @extraction_form = ExtractionForm.find(@quality_dimension_field.extraction_form_id)
      @project = Project.find(@extraction_form.project_id)  
      @quality_dimension_fields = QualityDimensionField.where(:extraction_form_id=>@extraction_form.id).order("question_number ASC")
    else
	    problem_html = create_error_message_html(@quality_dimension_field.errors)
	    flash[:modal_error] = problem_html
    end
  end
  
  # delete a quality dimension field (custom field)
  def destroy
    @quality_dimension_field = QualityDimensionField.find(params[:id])
    @extraction_form = ExtractionForm.find(@quality_dimension_field.extraction_form_id)
  	@project = Project.find(@extraction_form.project_id)
    QualityDimensionField.transaction do 
      ActiveRecord::Base.connection.execute("UPDATE quality_dimension_fields SET question_number = question_number - 1 WHERE extraction_form_id = #{@extraction_form.id} AND question_number > #{@quality_dimension_field.question_number};")
    end
    @quality_dimension_field.destroy
  
    @quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id).order("question_number ASC")    
  end

  def create_from_defaults
    unless params[:dimension_id] == ''
      QualityDimensionField.generate_quality_dimensions(params[:extraction_form_id], params[:dimension_id])
      
      @extraction_form = ExtractionForm.find(params[:extraction_form_id])
      @questions = QualityDetail.where(:extraction_form_id => @extraction_form.id).all.sort_by{|q| q.question_number}
      @model_name = "quality_detail"
      @class_name = "QualityDetail"
      @model_obj = QualityDetail.new 
      @model = @model_name.dup 
      @saved = true 
      render '/question_builder/create' 
    end
  end

  def reorder
    @project = Project.find(params[:project_id])
    @extraction_form = ExtractionForm.find(params[:extraction_form_id])
    qd = QualityDimensionField.find(params[:selector_id])
    unless qd.nil?
      new_row = params[:new_row_num]
      QualityDimensionField.transaction do 
        if qd.question_number.blank?
          QualityDimensionField.assign_initial_qnums(@extraction_form.id)
          qd = QualityDimensionField.find(params[:selector_id])
        end
        shift_question_numbers(qd, new_row)
        qd.question_number = new_row.to_i
        qd.save 
      end
    end
    @quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id).order("question_number ASC")
  end

  def shift_question_numbers(dimension, new_qnum)
    onum = dimension.question_number
    nnum = new_qnum.to_i 
    if onum < nnum 
      ActiveRecord::Base.connection.execute("update quality_dimension_fields set question_number = question_number - 1 where extraction_form_id = #{dimension.extraction_form_id} and question_number > #{onum} and question_number <= #{nnum};")
    elsif onum > nnum 
      ActiveRecord::Base.connection.execute("update quality_dimension_fields set question_number = question_number + 1 where extraction_form_id = #{dimension.extraction_form_id} and question_number < #{onum} and question_number >= #{nnum};")
    end
  end
end
