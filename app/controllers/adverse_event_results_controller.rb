# This controller handles the adverse event data points in a study, i.e. a form field item in a particular adverse_event(row) and adverse_event_column.
class AdverseEventResultsController < ApplicationController

  # save the new adverse event data points
  def create
    AdverseEventResult.save_data_points(params)
	  @message_div = "saved_item_indicator"
	  render "shared/saved.js.erb"
  end

  # save the updated adverse event data points
  def update
    AdverseEventResult.save_data_points(params, params[:study_id])	
	  @message_div = "adverse_event_validation_message"
	  render "shared/saved.js.erb"
  end


end