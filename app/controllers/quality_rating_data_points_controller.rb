# This controller handles the data points in the quality ratings section, in study data entry.
# The data point is what is saved when a user chooses a value from the study data quality rating select box and presses save, 
# and/or enters a note or description in that section.
class QualityRatingDataPointsController < ApplicationController
before_filter :require_user

  # create a new quality rating data point
  def create
    @quality_rating = QualityRatingDataPoint.new(params[:quality_rating_data_point])
    @study = Study.find(@quality_rating.study_id)
    @project = Project.find(@study.project_id)
		@exists = QualityRatingDataPoint.where(:study_id => params[:quality_rating_data_point][:study_id]).all
		if !@exists.nil?
			for qr in @exists
				qr.destroy
			end
		end
		if @saved = @quality_rating.save
		    @message_div = "saved_indicator_2"
		    #@table_container = "quality_rating_data_points_table"
			#@table_partial = "quality_rating_data_points/table"
		else
	       	problem_html = create_error_message_html(@quality_rating.errors, "")
			flash[:modal_error] = problem_html
			@error_partial = "layouts/modal_info_messages"
	    end
		@error_div = "validation_message_rtg"	
		render "shared/saved.js.erb"
  end

  # save updates to a quality rating data point
  def update
    begin 
    	@quality_rating = QualityRatingDataPoint.find(params[:id])
    	if @saved = @quality_rating.update_attributes(params[:quality_rating_data_point])
			@message_div = "saved_indicator_2"
		    #@table_container = "quality_rating_data_points_table"
			#@table_partial = "quality_rating_data_points/table"
	   else
			problem_html = create_error_message_html(@quality_rating.errors)
			flash[:modal_error] = problem_html
			@error_partial = "layouts/modal_info_messages"
			@error_div = "validation_message_rtg"
		end
    rescue
    	@quality_rating = QualityRatingDataPoint.create(params[:quality_rating_data_point])
    end
    
	render "shared/saved.js.erb"
  end

  # delete a quality rating data point
  def destroy
    @quality_rating = QualityRatingDataPoint.find(params[:id])
    @quality_rating.destroy
  end
end
