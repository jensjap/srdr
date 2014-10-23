# this controller handles creation and deletion of requests
# to download data for a project
class DataRequestsController < ApplicationController

  # save the new arm detail data point
  def create
    dr = DataRequest.new
    dr.user_id = current_user.id 
    dr.requested_at = Time.now()
    dr.request_count = 1
    dr.project_id = params[:project_id]
    dr.save
    @project = Project.find(dr.project_id)
    @message = "Your data request has been submitted."
  end

  def edit
    if (Time.now() - dr.requested_at) > 3.days
      dr.requested_at = Time.now()
      dr.request_count += 1
      dr.save
      # Send an email

      @message = "Your request has been updated. We will notify the project lead of your interest."
    else
      # Notify that the user cannot request again so soon
      @message = "Your previous request is still being processed. Please allow at least 3 days between requests. You may submit another request on "+ (dr.requested_at + 3.days).to_s
    end
  end

end
