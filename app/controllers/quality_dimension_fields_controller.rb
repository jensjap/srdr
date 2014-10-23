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

  # save updates to a quality dimension field (custom field)
  def create
  	@quality_dimension_field = QualityDimensionField.new(params[:quality_dimension_field])
	@extraction_form = ExtractionForm.find(@quality_dimension_field.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)	
	@already_saved = false
	if (params[:quality_dimension_field][:title][0,8] == "add all ")
		QualityDimensionField.add_all_dimensions_from_section(params[:quality_dimension_field][:title], @extraction_form.id)
		@quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id).all
		@already_saved = true
	end
	if (!@already_saved)
		if (@saved = @quality_dimension_field.save)
			if !params[:study_id].nil?
				@study = Study.find(params[:study_id])
				@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @quality_dimension_field.extraction_form_id).all
				@quality_dimension_data_point = QualityDimensionDataPoint.new
				@study_arms = Arm.where(:study_id => @study.id, :extraction_form_id => @quality_dimension_field.extraction_form_id).all
			else
				if (params[:quality_dimension_field][:title] == "other")
					@quality_dimension_field.title = params[:quality_dimension_field_title_other]
				elsif (params[:quality_dimension_field][:title] == "")
					@quality_dimension_field.destroy
					problem_html = "That is not a valid selection. Please choose a valid dimension from the list or choose 'Other'."	
				else
					@quality_dimension_field.save
					@quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => @quality_dimension_field.extraction_form_id).all
				end
			end
		else
			problem_html = create_error_message_html(@quality_dimension_field.errors)
			flash[:modal_error] = problem_html
		end
	end
  end

  # save changes/update an existing quality dimension field (custom field)
  def update
    @quality_dimension_field = QualityDimensionField.find(params[:id])
	@quality_dimension_field.update_attributes(params[:quality_dimension_field])
	@extraction_form = ExtractionForm.find(@quality_dimension_field.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)	
    if @saved = @quality_dimension_field.save
		if !params[:study_id].nil?
			extraction_form_id = @quality_dimension_field.extraction_form_id
			@study = Study.find(params[:study_id])
			if !extraction_form_id.nil?
				@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => extraction_form_id).all
			else
				@quality_dimension_extraction_form_fields = nil
			end
			@quality_dimension_data_point = QualityDimensionDataPoint.new
			@study_arms = Arm.where(:study_id => @study.id, :extraction_form_id => extraction_form_id).all		
		else
			if @quality_dimension_field.title == "other"
				@quality_dimension_field.title = params[:quality_dimension_field_title_other]
			elsif @quality_dimension_field.title.starts_with?("all ")
				QualityDimensionField.add_all_dimensions_of_title_type(@quality_dimension_field)
			end
			if @quality_dimension_field.title == ""
				problem_html = "That is not a valid selection. Please choose a valid dimension from the list or choose 'Other'."
			else	
				@quality_dimension_field.save
				@quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => @quality_dimension_field.extraction_form_id).all
			end	
		end
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
end
