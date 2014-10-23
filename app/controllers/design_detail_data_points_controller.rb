# this controller handles creation and deletion of data points for design details, in the study data entry section. A design detail
# data point is created when a user presses "save" on a study data entry form.
class DesignDetailDataPointsController < ApplicationController

  # save new design detail data point
  def create
	successful = DesignDetailDataPoint.save_data(params, params[:design_detail_data_point][:study_id]) 
  	if successful
  		@message_div = "saved_indicator_1"
  		render "shared/saved.js.erb"
  	end
  end
  
  # delete existing design detail data point
  def destroy
    @design_detail_data_point = DesignDetailDataPoint.find(params[:id])
    @design_detail_data_point.destroy
  end
  
  
end
