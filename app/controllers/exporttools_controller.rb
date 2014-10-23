class ExporttoolsController < ApplicationController
    # Export Tools Controller
    # index
    def index
        prj_id = params[:prjid]
        puts "Export tools - project id "+prj_id.to_s
        session[:export_project] = prj_id
        @project = Project.find(:first, :conditions=>["id = ?", prj_id])
		@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
        puts "Export tools - done project id "+prj_id.to_s
    end
    
    def simpleexport
        prj_id = params[:prjid]
        puts "Simple Export tools - project id "+prj_id.to_s
        session[:export_project] = prj_id
        @project = Project.find(:first, :conditions=>["id = ?", prj_id])
	@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
        puts "Simple Export tools - done project id "+prj_id.to_s
    end
    
    def reportbuilder
        prj_id = params[:prjid]
        puts "Report Builder - project id "+prj_id.to_s
        session[:export_project] = prj_id
        @project = Project.find(:first, :conditions=>["id = ?", prj_id])
	@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
        puts "Report Builder - done project id "+prj_id.to_s
    end
    
    def advexport
        prj_id = params[:prjid]
        puts "Report Builder - project id "+prj_id.to_s
        session[:export_project] = prj_id
        @project = Project.find(:first, :conditions=>["id = ?", prj_id])
	@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
        puts "Report Builder - done project id "+prj_id.to_s
    end
end
