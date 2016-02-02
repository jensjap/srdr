# this controller contains global functions for the application.
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user, :set_as_current
  # rescue errors
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
  	rescue_from ActionController::UnknownAction, :with => :render_not_found
  end   
    
	# When the 'other' option is selected from a dropdown menu, 
	# show an input text box.
	def show_other
		@field_size = params[:field_size].nil? ? "small" : params[:field_size]
		@field_id = params[:field_id]
		if !params.nil? && !params[:selected].nil?
			sel = params[:selected].downcase	
			if !sel.nil? && (sel.match(/^other\.{3}?$/i))
				@field_name = params[:field_name]
				@new_field_id = 'other_' + @field_id.to_s				
				render 'specify_other/show_input.js.erb'
			else
				@new_field_id = 'other_' + @field_id.to_s
				render 'specify_other/remove_input.js.erb'
			end	
		else
			@new_field_id = 'other_' + @field_id.to_s	
			render 'specify_other/remove_input.js.erb'
		end	
	end
	
	# render the javascript file that shows the "other" field with a filled in value
	def show_other_filled
		@field_size = params[:field_size].nil? ? "small" : params[:field_size]
		@field_id = params[:field_id]
		@value = params[:value]
		@name = params[:field_name]
		render 'specify_other/show_other_filled.js.erb'		
	end
  
  
	# call this function for form elements that may end up with quotes in their value
	# @param [string] input 
	# @return [string] output the escaped string
	def escape_quotes input
		input.gsub!(/([\'\"])/,"\\\1")  #single quote
		
		return input
	end
	
	# used in layouts/header - navigation links
	# used to set CSS for tabs at the top of the page (as of 1/13/2012)
	# @param [string] request_uri request url to generate current page from
	# @param [string] pagename the page name to match with the request uri
	# @return [string] ret a string to denote the current page
	def set_as_current(request_uri, pagename)
		case pagename
			when "forms"
				if request_uri == "/extraction_forms?all=true"
					return " current"		
				end
			when "published"
				if request_uri == "/projects/published"
					return " current"		
				end			
			when "myprojects"
				if request_uri == "/projects"
					return " current"		
				end			
			when "home"
				if request_uri == "/"
					return " current"		
				end			
			when "login"
				if request_uri == "/login"
					return " current"		
				end			
			when "register"
				if request_uri == "/register"
					return " current"		
				end			
			when "feedback"
				if request_uri == "/feedback"
					return " current"		
				end			
			when "help"
				if request_uri == "/help"
					return " current"		
				end			
			when "account"
				if request_uri == "/account"
					return " current"		
				end			
			else
			end
	end 
	
	# When a user chooses to hide the ahrq header, set a session variable to be used
	# on subsequent pages
	def toggle_ahrq_header
		@display = params[:display]
		val = "show"
		if session[:ahrq_header].nil?
		  val = 'hide'
		elsif session[:ahrq_header] == 'show'
			val = 'hide'
    end
	  session[:ahrq_header] = val
	  render "shared/toggle_ahrq_header.js.erb"
	end
	
	# Authlogic - get whether current user session exists
	# @return [UserSession] current_user_session the current session for the user that is currently logged in
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

	# Authlogic - get current_user object
	# @return [User] current_user the current user object (user that is logged in)
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    # Authlogic - require a user to access a page
    # @return [boolean] ret if the user is not logged in
    def require_user
      unless current_user
        store_location
        flash[:notice] = ": You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_project_membership
      user       = current_user()
      project_id = params[:project_id].nil? ? params[:id] : params[:project_id]
      project    = Project.find(project_id)

      _validate_project_membership(project, user)
    end

    # Redirect to project root page if user is not a member of the project
    # or the project has not been published
    def _validate_project_membership(project, user)
      project_id = project.id

      unless (project.is_public)
        if user.nil?
          store_location
          flash[:notice] = ": The resource you are attempting to access has not been made public and you do not have authorization to view the content. If you believe this to be an error, please contact your administrator."
          redirect_to projects_path
        else
          user_type = user.user_type
          unless user_type == 'super-admin'
            user_id = user.id
            set_of_project_member_ids = _find_set_of_project_member_ids(project_id)
            unless set_of_project_member_ids.include?user_id
              store_location
              flash[:notice] = ": The resource you are attempting to access has not been made public and you do not have authorization to view the content. If you believe this to be an error, please contact your administrator."
              redirect_to projects_path
            end
          end
        end
      end
    end

    # Returns an array with members of the given project id
    def _find_set_of_project_member_ids(project_id)
      set_of_project_members = Set.new

      user_project_roles = UserProjectRole.find(:all, :conditions => { :project_id => project_id })
      user_project_roles.each do |i|
        set_of_project_members.add i.user_id
      end

      project_creator_id = project_creator_id(project_id)

      set_of_project_members.add project_creator_id
    end

    # Finds project creator id from Projects table by project id
    def project_creator_id(project_id)
      project = Project.find(project_id)
      project.creator_id
    end
    
    # require the user to be a lead on a project in order to edit and manage it
		# @return [boolean] ret if the user does not have privileges
    def require_lead_role
    	proj_id=""
    	if session[:project_id].nil?
    		proj_id = params[:project_id].nil? ? params[:id] : params[:project_id]
		  else
		  	proj_id = session[:project_id]
		  end
		      	  	
    	unless User.current_user_has_project_edit_privilege(proj_id, current_user)   		
    		if User.current_user_has_study_edit_privilege(proj_id, current_user)
    			flash[:notice] = "Your access level does not allow you to edit the project details."
    			redirect_to "/projects/"+proj_id.to_s+"/studies"
    		else
    			flash[:notice] = ": You have not been granted access to this resource."
    			redirect_to "/"
    		end
    		return false
    	end
    end

    def require_admin
    	unless User.hasAdminRights(current_user)
    		flash[:notice] = "You do not have access to this page."
    		redirect_to "/"
    	end
    end
		
    # require that the user be an editor on the project in order to view/add/edit studies
    # @return [boolean] ret if the user does not have privileges
    def require_editor_role
        proj_id = ""
        if session[:project_id].nil?
            proj_id = params[:project_id].nil? ? params[:id] : params[:project_id]
        else
            proj_id = session[:project_id]
        end

        unless (User.current_user_has_study_edit_privilege(proj_id, current_user))
            flash[:notice] = "You do not have the ability to edit studies for this project. Please contact the project lead if you believe an error has occurred."
            redirect_to "/projects/#{proj_id.to_s}/studies"
            return false
        end
    end
    
	# require that a user owns a extraction_form before accessing it
	# @return [boolean] ret if the user does not have privileges
 	def require_extraction_form_ownership
 		extraction_form_id = params[:extraction_form_id]
 		extraction_form = ExtractionForm.find(extraction_form_id, :select=>["creator_id"])
 		unless extraction_form.creator_id == current_user.id
 			flash[:notice] = "You do not have ownership of the extraction form, and therefore cannot make edits."
 			redirect_to "/extraction_forms/#{extraction_form_id.to_s}"
 			return false
 		end
 	end
 		
	# require that no user is logged in before seeing a page	
	# @return [boolean] 
 	def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to ""
        return false
      end
    end

	# Use user roles to test if a user is a project lead
	# @return [boolean]
	def is_lead
		if !params[:project_id].nil? || params[:project_id] != ""
			@project = Project.find(params[:project_id])
			@user_role = UserProjectRole.where(:project_id => @project.id, :user_id => current_user.id).first
			if @user_role.role == 'lead'
				return true
			end
		end
		return false
	end
	
	# save :return_to in order to go back later ... ?
	# may not need this
    def store_location
      #session[:return_to] = request.request_uri
      session[:return_to] = request.fullpath
    end

	# Authlogic - redirect to previous page or to default page
	# @param [string] default the default url to redirect to
  def redirect_back_or_default(default)
    redirect_to(default)
  end
  
	# gather footnote information from the parameter and return an array of footnote hashes
	# @param [hash] form_params the parameters from the form submit
	# @return [array] footnotes the footnotes array
  def get_footnotes_from_params(form_params)
		footnotes = Array.new
		form_params.keys.each do |key|
			if key =~ /_footnote_/
				
				# the key being split would be something like:
				# categorical_footnote_1  or continuous_footnote_1
				note_parts = key.split("_");
				
				tmp_note = {:note_number=>note_parts[2],
										:study_id=>session[:study_id],
										:note_text=>form_params[key],
										:page_name=>"results",
										:data_type => note_parts[0]}							 
				footnotes << tmp_note
			end
		end
		return footnotes
  end
	

  private
  # render the layout and error message page for a not-found error
  # @param [exception] exception the exception  
  def render_not_found(exception = nil)
	respond_to do |format|
		format.html{	
			render :file => "/app/views/errors/404.html.erb", :status => 404, :layout => "application"	
		}
		format.xml  { head :not_found }
		format.any  { head :not_found }	
	end
  end
  
# render the layout and error message page for an error
# @param [exception] exception the exception
  def render_error(exception = nil)
	respond_to do |format|
		format.html{
			render :file => "/app/views/errors/500.html.erb", :status => 500, :layout => "application"
		}
		format.xml  { head :not_found }
		format.any  { head :not_found }	
	end
  end
	
	# create html for displaying an error message.
	# @param [Array] errors_arr array of errors to turn into an html string
	# @return [String] problem_html the html to display in the error message
	def create_error_message_html(errors_arr)
		problem_html = "The following errors prevented the question from being saved:\n<ul>"
		for i in errors_arr
			problem_html += "<li>" + i.to_s + " " + errors_arr[i][0] + "</li>"
		end
		problem_html += "</ul>Please correct the form and press 'Save' again."
		return problem_html
	end	

	# create html for displaying an error message.
	# @param [Array] errors_arr array of errors to turn into an html string
	# @return [String] problem_html the html to display in the error message
	def get_error_HTML(errors=[])
		problem_html = ""
		unless errors.empty?
			problem_html = "<div style='border: 4px solid red; background-color:#ecc5b8; padding:5px; color:black; margin:5px;'><strong>The following errors have occurred:</strong><br/><br/><ul style='list-style-type:disc;margin-left:20px;'>"
			errors.each do |e|
				problem_html += "<li>#{e}</li>"
			end
			problem_html += "</ul><br/><br/></div>"
		end
		return problem_html
	end	

    # create html for displaying a success message.
    # @param [Array] errors_arr array of errors to turn into an html string
    # @return [String] problem_html the html to display in the error message
    def get_success_HTML(msgs=[])
        success_html = ""
        unless msgs.empty?
            success_html = "<div style='border: 4px solid #0a460f; background-color: #e0f4dd; padding:5px; color:black; margin:5px;'><strong>Success!</strong><br/><br/><ul style='list-style-type:disc;margin-left:20px;'>"
            msgs.each do |m|
                success_html += "<li>#{m}</li>"
            end
            success_html += "</ul><br/><br/></div>"
        end
        return success_html
    end 
  
  # clearSessionProjectInfo
  # clear systematic review project info from the session
  def clearSessionProjectInfo
  	session[:project_id] = nil
  	session[:project_title] = nil
  	session[:project_status] = nil
  	session[:study_id] = nil
  	session[:study_title] = nil
  	session[:extraction_form_id] = nil
  end
end
