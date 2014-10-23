# this controller handles creation and deletion of data points for baseline characteristics, in the study data entry section. A Baseline Characteristic 
# data point is created when a user presses "save" on a study data entry form.
class BaselineCharacteristicDataPointsController < ApplicationController

  # save the new baseline characteristic data point
  def create
	successful = BaselineCharacteristicDataPoint.save_data(params, params[:baseline_characteristic_data_point][:study_id]) 
	if successful    
		@message_div = "saved_indicator_1"
		render 'shared/saved.js.erb'
	end
  end

  # delete the baseline characteristic data point
  def destroy
    @baseline_characteristic_data_point = BaselineCharacteristicDataPoint.find(params[:id])
    @baseline_characteristic_data_point.destroy
  end
  
  
end
