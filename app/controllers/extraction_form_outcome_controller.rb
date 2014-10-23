# this controller handles creation and editing of arm suggestions - when a contributor adds arm names to the extraction form.
class ExtractionFormOutcomeController < ApplicationController
    before_filter :require_user
    respond_to :js, :html
  
    def add_instr
      	@editing = false
    	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
    	@project = Project.find(params[:project_id])
    	@section = params[:section]
    	@data_element = params[:data_element]
        @extraction_form_outcomes_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "OUTCOMES", "GENERAL"])
        if @extraction_form_outcomes_instr.nil?
            @extraction_form_outcomes_instr = EfInstruction.new
        end
    end

end