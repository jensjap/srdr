# This model handles the options in the quality ratings section, in extraction form creation. The default values are Good, Fair and Poor. 
# The default values are set in config/default_questions.yml.
class QualityRatingFieldsController < ApplicationController

  # create new quality rating field
  def new
    @quality_rating_field = QualityRatingField.new
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])	
	@editing_rtg=false
  end

  # save changes to existing quality rating field
  def edit
    @quality_rating_field = QualityRatingField.find(params[:id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@has_study_data = QualityRatingField.has_study_data(@extraction_form.id)	
    @editing_rtg=true
  end

  # save new  quality rating field
  def create
    @quality_rating_field = QualityRatingField.new(params[:quality_rating_field])
    display_num = @quality_rating_field.get_display_number(params[:extraction_form_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@quality_rating_field.display_number = display_num	
    if @saved = @quality_rating_field.save
		@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => params[:extraction_form_id]}, :order => "display_number ASC")	
	else
		@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => params[:extraction_form_id]}, :order => "display_number ASC")	
		problem_html = create_error_message_html(@quality_rating_field.errors)
		flash[:modal_error] = problem_html
    end
	@editing_rtg = false
  end

  # save changes to existing quality rating field
  def update
    @quality_rating_field = QualityRatingField.find(params[:id])
	@extraction_form = ExtractionForm.find(@quality_rating_field.extraction_form_id)
    if @saved = @quality_rating_field.update_attributes(params[:quality_rating_field])
		@editing_rtg = false
    	@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => @extraction_form.id}, :order => "display_number ASC")
  		@quality_rating_field = QualityRatingField.new
	else
		@editing_rtg = true
		@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => @extraction_form.id}, :order => "display_number ASC")	
		problem_html = create_error_message_html(@quality_rating_field.errors)
		flash[:modal_error] = problem_html
	end
  end

  # move the quality rating field up in the list
  def moveup
    @quality_rating_field = QualityRatingField.find(params[:quality_rating_field_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])		
	QualityRatingField.move_up_this(params[:quality_rating_field_id].to_i, params[:extraction_form_id])
	@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => params[:extraction_form_id]}, :order => "display_number ASC")
	@div_name = "quality_rating_fields_table"
	@partial_name = "quality_rating_fields/table"
	@quality_rating_field = QualityRatingField.new
	render "shared/render_partial.js.erb"
  end    
  
  # confirm deletion before destroying
  def confirm_delete
    @quality_rating_field = QualityRatingField.find(params[:id])
	  @extraction_form = ExtractionForm.find(params[:extraction_form_id])
	  @project = Project.find(@extraction_form.project_id)
	  @has_study_data = QualityRatingField.has_study_data(@extraction_form.id)		
  end
  
  # delete existing quality rating field
  def destroy
    qrf = QualityRatingField.find(params[:id])
    qrf.shift_display_numbers(qrf.extraction_form_id)
    QualityRatingField.destroy(qrf.id)
    @extraction_form = ExtractionForm.find(qrf.extraction_form_id)  
    @quality_rating_fields = QualityRatingField.find(:all, :conditions=>["extraction_form_id=?",@extraction_form.id], :order=>["display_number ASC"])
  end
end
