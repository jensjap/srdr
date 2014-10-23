# this controller handles showing of main srdr pages
class HomeController < ApplicationController
  layout :determined_by_request
  before_filter :require_admin, :only=>[:user_list]

  # "srdr home" -
  # show SRDR main page
  def index
     @user_session = UserSession.new
     # Load recently completed reports
     @recent_reports = Recentreports.new
     @mostviewed_reports = Mostviewedreports.new
     @events = Srdrevents.new
     session[:items_per_page] = session[:items_per_page].nil? ? 10 : session[:items_per_page]
  end

  # for all users, show the about srdr page
  def about
  end

  # show help page
  def help
    @selected = params[:selected].nil? ? 0 : params[:selected]
  end

  # show srdr policies
  def policies
  end

  # CSS DESIGN TESTING
  def css_markup
    render :layout=>false
  end

  def css_markup_home
    render :layout=>false
  end

  # show the feedback form page
  def feedback
    render 'feedback_items/feedback_form'
  end

  def user_list
    @users = User.find(:all, :order=>"lname ASC");
  end

  # submit a user's feedback to the database
  def send_feedback
    feedback = FeedbackItem.new(:user_id=>current_user.id, :url=>params[:url], :page=>params["feedback-form-select"], :description=>params[:description])
    if @saved = feedback.save
        flash[:success_message] = "Thank you for your feedback. We will inform you when this issue has been resolved."
    else
        flash[:error_message] = "We're sorry, but we could not complete this request. Please send an email to cparkin@tuftsmedicalcenter.org with a description of the problem."
    end
    render 'feedback_items/feedback_submit.js.erb'
  end
  # a basic 'coming soon' page
  def coming_soon
    respond_to do |format|
      format.js{ render "coming_soon.js.erb"}
      format.html{ render "coming_soon.html.erb"}
    end
  end
  # show demo video 1
  def demo1
  end

  # show demo video 2
  def demo2
  end

  # show demo video 3
  def demo3
  end

 protected
 # show layout depending on type of request - i.e. don't show full header for ajax requests
 def determined_by_request
   if request.xhr?
     return false
   else
     'application'
   end
 end


end
