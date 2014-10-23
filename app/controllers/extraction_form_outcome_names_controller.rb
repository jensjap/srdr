# this controller handles creation and editing of outcome suggestions - when a contributor adds outcome names to the extraction form.
class  ExtractionFormOutcomeNamesController < ApplicationController
 
	# create new suggested outcome name
  def new
    @extraction_form_outcome_name =  ExtractionFormOutcomeName.new
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@editing = false
  end
  
	# edit existing suggested outcome name
  def edit
    @extraction_form_outcome_name =  ExtractionFormOutcomeName.find(params[:id])
	@extraction_form = ExtractionForm.find(@extraction_form_outcome_name.extraction_form_id)
	@project = Project.find(@extraction_form.project_id)
	@editing = true
	@extraction_form_outcome_name =  ExtractionFormOutcomeName.find(params[:id])
  end

	# save new suggested outcome name
  def create
    @extraction_form_outcome_name =  ExtractionFormOutcomeName.new(params[:extraction_form_outcome_name])
	@extraction_form_id = ExtractionForm.find(@extraction_form_outcome_name.extraction_form_id)
	@editing = false
    if @saved = @extraction_form_outcome_name.save
		@saved_names =  ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form_outcome_name.extraction_form_id)
		@extraction_form_outcome_name =  ExtractionFormOutcomeName.new		
	else
		problem_html = create_error_message_html(@extraction_form_outcome_name.errors)
		flash[:modal_error] = problem_html
    end
  end

	# update existing suggested outcome name
  def update
    @extraction_form_outcome_name =  ExtractionFormOutcomeName.find(params[:id])
		@extraction_form_id = ExtractionForm.find(@extraction_form_outcome_name.extraction_form_id)
		previous_outcome_title = @extraction_form_outcome_name.title
		@editing = false	
    if @saved = @extraction_form_outcome_name.update_attributes(params[:extraction_form_outcome_name])
    	@saved_names =  ExtractionFormOutcomeName.where(:extraction_form_id=>@extraction_form_outcome_name.extraction_form_id)
		@extraction_form_outcome_name.update_studies(previous_outcome_title)
    	@extraction_form_outcome_name =  ExtractionFormOutcomeName.new
    else
		problem_html = create_error_message_html(@extraction_form_outcome_name.errors)
		flash[:modal_error] = problem_html
    end  
  end

	# destroy suggested outcome name
  def destroy
    @extraction_form_outcome_name =  ExtractionFormOutcomeName.find(params[:id])
	@extraction_form = ExtractionForm.find(@extraction_form_outcome_name.extraction_form_id)
	@editing = false	
    @extraction_form_outcome_name.destroy
	@saved_names =  ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form.id)
	@extraction_form_outcome_name =  ExtractionFormOutcomeName.new
    @div_name = "table_div"
	@partial_name = "extraction_form_outcome_names/table"
    @div2_name = "new_outcome_entry"
	@partial2_name = "extraction_form_outcome_names/form"
	render "shared/render_partial.js.erb"
  end
end
