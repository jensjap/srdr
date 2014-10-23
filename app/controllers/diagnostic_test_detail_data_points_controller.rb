# this controller handles creation and deletion of data points for diagnostic test details, in the study data entry section. 
# A diagnostic test detail data point is created when a user presses "save" on a study data entry form.
class DiagnosticTestDetailDataPointsController < ApplicationController

  # save new design detail data point
  def create
    successful = DiagnosticTestDetailDataPoint.save_data(params, params[:diagnostic_test_detail_data_point][:study_id]) 
    if successful
        @message_div = "saved_indicator_1"
        render "shared/saved.js.erb"
    end
  end
  
  # delete existing design detail data point
  def destroy
    @diagnostic_test_detail_data_point = DiagnosticTestDetailDataPoint.find(params[:id])
    @diagnostic_test_detail_data_point.destroy
  end
  
  
end
