# this controller handles creation and deletion of data points for arm details, in the study data entry section. An arm detail
# data point is created when a user presses "save" on a study data entry form.
class ArmDetailDataPointsController < ApplicationController

  # save the new arm detail data point
  def create
    puts "Params are #{params}\n\n"
  	successful = ArmDetailDataPoint.save_data(params, params[:arm_detail_data_point][:study_id]) 
  	if successful    
  		@message_div = "saved_indicator_1"
  		render 'shared/saved.js.erb'
  	end
  end

  # delete the arm detail data point
  def destroy
    @arm_detail_data_point = ArmDetailDataPoint.find(params[:id])
    @arm_detail_data_point.destroy
  end

end
