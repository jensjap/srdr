# this controller handles errors - shows a 404 for routing errors, and renders a not_found error (in application_controller) for other errors.
class ErrorsController < ApplicationController

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end   

  # show 404 page for a routing error
  def routing
    @error = "No page for URL " + request.url
		respond_to do |format|
			format.html{	
				render :file => "/app/views/errors/404.html.erb", :status => 404, :layout => "application"	
			}
			format.xml  { head :not_found }
			format.any  { head :not_found }	
		end
  end
end
