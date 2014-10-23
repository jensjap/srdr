# this controller handles creation and deletion of data points for design details, in the study data entry section. A design detail
# data point is created when a user presses "save" on a study data entry form.
class OutcomeDetailDataPointsController < ApplicationController

  # save new design detail data point
  def create
	successful = OutcomeDetailDataPoint.save_data(params, params[:outcome_detail_data_point][:study_id]) 
  	if successful
  		@message_div = "saved_indicator_1"
  		render "shared/saved.js.erb"
  	end
  end
  
  # delete existing design detail data point
  def destroy
    @outcome_detail_data_point = OutcomeDetailDataPoint.find(params[:id])
    @outcome_detail_data_point.destroy
  end
  
  
end
