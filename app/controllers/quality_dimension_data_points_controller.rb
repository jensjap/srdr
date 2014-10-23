# This controller handles creation, updating and deletion of data points in the quality dimensions table, in study data entry.
class QualityDimensionDataPointsController < ApplicationController

  # save a new quality dimension data point
  def create
	@saved =QualityDimensionDataPoint.save_data_points(params[:quality_dimension_data_point][:study_id], params[:quality_dimension_data_point][:extraction_form_id], params)
	@message_div = "saved_indicator_1"
	render 'shared/saved.js.erb'
  end

  # save updates to an existing quality dimension data point
  def update
    @quality_dimension_data_point = QualityDimensionDataPoint.find(params[:id])
    @quality_dimension_data_point.update_attributes(params[:quality_dimension_data_point])
  end

  # delete an existing quality dimension data point
  def destroy
    @quality_dimension_data_point = QualityDimensionDataPoint.find(params[:id])
    @quality_dimension_data_point.destroy
  end
  
  
end
