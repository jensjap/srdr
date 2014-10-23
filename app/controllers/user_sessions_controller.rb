# encoding: UTF-8

# This controller handles creation and deletion of user sessions - login and logout - via the authlogic authentication gem.
# For more information see: https://github.com/binarylogic/authlogic
# For specifics about setting up authlogic on rails 3, see http://www.dixis.com/?p=352
class UserSessionsController < ApplicationController
    before_filter :require_no_user, :only => [:create]
    before_filter :require_user, :only => :destroy

    # show login screen
    def new
        @user_session = UserSession.new
        if current_user.nil?
            @page_title = "Log In"
        else
            @page_title = "Logged in as " + @current_user.login
        end
    end

    # log the user in
    def create
        params[:user_session][:login].downcase!
        # First check if user account is an admin account
        user = User.find(:first, :conditions=>["login = ?",params[:user_session][:login]])
        error_str = ""
        if user.nil?
            error_str = error_str + "- Invalid login"
        else
            userorgroles = UserOrganizationRole.find(:first, :conditions=>["user_id = ?",user.id])
            if userorgroles.nil?
                error_str = error_str + "- Cannot find user roles/credentials"
            elsif !(userorgroles.status == "VALID")
                error_str = error_str + "- Account is not a valid account"
            end
        end
        if error_str.length > 0
            flash[:error] = " Cannot log you into the SRDR website due to " + error_str
            @page_title = "Log In"
            #redirect_to "/"
            redirect_to login_path
            session[:project_id] = nil
            session[:project_title] = nil
            session[:study_id] = nil
        else
            @user_session = UserSession.new(params[:user_session])
            if @user_session.save
                current_user = UserSession.find
                # MK - don't need to display this anymore
                flash[:success] = " Login successful!"
                @lead_projects = User.get_user_lead_projects(current_user)
                @collab_projects = User.get_user_editor_projects(current_user)
                if User.hasAdminRights(user)
                    @all_projects = Project.find(:all)
                end
                clearSessionProjectInfo()
                redirect_to "/projects"
            else
                str = ""
                @user_session.errors.each do |key, value|
                    str += "#{key.to_s} #{value.to_s}"
                end
                flash[:error] = " There was a problem logging you in: Your " + str + "."
                @page_title = "Log In"
                redirect_to "/"
            end
        end
    end

    # delete the user session, i.e. log the user out
    def destroy
        #puts ".............>>>>>>>>>> user_session_controller::destroy - removing user session "+current_user_session.id.to_s
        current_user_session.destroy

        # Clean up any old sessions
        #current_user_session.clearOldSessions

        # MK - don't need to display this anymore
        flash[:success] = " You have successfully logged out."
        session[:project_id] = nil
        session[:project_title] = nil
        session[:study_id] = nil

        # Jump to home page
        redirect_to "/"
    end
end
