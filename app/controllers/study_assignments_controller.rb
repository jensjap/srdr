# this controller handles creation, editing, updating, moving-up-in-a-list and deletion of arms in study data entry.
class StudyAssignmentsController < ApplicationController
  before_filter :require_lead_role, :only => [:show, :update] 
  # show the form for reassigning a study from one user to another
  def show
    study_id = params[:study_id]
    creator_id = params[:creator_id]
    @study = Study.find(:first, :conditions=>["id=?",study_id], :include=>[:primary_publication, :primary_publication_numbers])
    @user_studies = Study.joins(:primary_publication).find(:all, :conditions=>["creator_id = ? and studies.id <> ? and project_id = ?",creator_id, study_id, @study.project_id], :include=>[:primary_publication, :primary_publication_numbers], :order=>["title ASC"])
    all_user_ids = UserProjectRole.find(:all, :conditions=>["project_id=? AND role IN (?)", @study.project_id, ["lead","editor"]], :select=>["user_id"])
    @all_users = User.find(:all, :conditions=>["id IN (?)", all_user_ids.collect{|x| x.user_id}], :order=>["login ASC"])
  end

  # carry out the study re-assignment operation 
  def update
    new_user_id, new_user_login = params[:new_user].split("|")
    old_user_id = params[:old_user_id]
    old_user_login = params[:old_user_login]
    
    studies = params[:studies_to_update]
    study_id = params[:study_id]
    
    flash[:success_html] = get_success_HTML(["User assignments have been successfully updated from #{old_user_login} to #{new_user_login} for the #{studies.length} studies requested. Please check the study list to verify your changes."])
    Study.transaction do 
      begin
        Study.update(studies, [{:creator_id=>new_user_id}] * studies.length)
      rescue Exception => e 
        puts "ERROR: #{e.message}\n\n#{e.backtrace}\n\n"
        flash[:success_html] = nil
        flash[:error_html] = get_error_HTML(["We're sorry, but the requested study re-assignment was unsuccessful. No studies were re-assigned. Please contact us to remedy this problem."])
      end
    end

    redirect_to "/projects/#{params[:project_id]}/studies"
  end

    
end
