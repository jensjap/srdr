# encoding: UTF-8

# This controller handles creation, deletion, and updating of users.
# The user class is linked to the authlogic authentication gem. This enables authentication/login and logout,
# password encryption and password resetting. For more information see: https://github.com/binarylogic/authlogic
# For specifics about setting up authlogic on rails 3, see http://www.dixis.com/?p=352
class UsersController < ApplicationController
    before_filter :require_no_user, :only => [:new, :create]
    before_filter :require_user, :only => [:show, :edit, :update, :email_preferences]


    # show the user registration screen
    def new
        @user = User.new
        @page_title = "Register"
        @editing = false
    end

    # register a new user
    def create
        # First check user agrees to terms of use
        user_agreement = params["user_agreement"]
        if user_agreement.nil? || !(user_agreement == "1")
            msg = " Registration Unsuccessful: You must agree to the SRDR Usage Policies "
            flash[:error] = "#{msg}"
            redirect_to "/register/agreement_error.html"
            return
        end

        @user = User.new(params[:user])
        @user.user_type = params[:user][:user_type]

        # Ensure text data is UTF-8 compliant
        @user.login.downcase!
        @user.email.downcase!
        @user.login = @user.login.force_encoding("UTF-8")
        @user.fname = @user.fname.force_encoding("UTF-8")
        @user.lname = @user.lname.force_encoding("UTF-8")
        @user.email = @user.email.force_encoding("UTF-8")
        @user.organization = @user.organization.force_encoding("UTF-8")
        account_type = params["account_type"]
        if account_type == "TRAINING"
            # Mark user type as active member
            @user.user_type = "member";
        end

        if @user.save
            # Generate validation code based on today's date and time stamp
            #validationcode = Time.now.to_s
            @registration = Registar.new
            @registration.login = @user.login
            @registration.email = @user.email
            @registration.fname = @user.fname
            @registration.lname = @user.lname
            @registration.organization = @user.organization
            if account_type == "PUPLIC"
                # Mark as waiting for validation E-mail response
                @registration.status = "VALIDATION"
            elsif account_type == "TRAINING"
                # Mark as immediately validated and assign roles
                @registration.status = "APPROVED"
                @organization = Organizations.find(:first, :conditions=>["name = ?",@user.organization])
                if @organization.nil? &&
                    !@user.organization.nil? &&
                    (@user.organization.length > 0)
                    @organization = Organizations.new
                    @organization.name = @user.organization
                    @organization.description = @user.organization
                    @organization.contact_name = @user.email
                    @organization.save
                end
                @userorgroles = UserOrganizationRole.new
                @userorgroles.user_id = @user.id
                @userorgroles.role = "contributor"
                @userorgroles.status = "VALID"
                @userorgroles.organization_id = @organization.id
                @userorgroles.updated_at = Time.now
                @userorgroles.save
            else
                # Mark as waiting for review
                @registration.status = "PENDING"
            end
            @registration.validationcode = (1000 * Time.now.to_f).to_i.to_s
            @registration.created_at = Time.now
            @registration.updated_at = Time.now
            @registration.save

            # Get site properties
            siteproperties = session[:guiproperties]
            if siteproperties.nil?
                siteproperties = Guiproperties.new
                session[:guiproperties] = siteproperties
            end
            flash[:success] = " Registration was successful."
            if account_type == "PUPLIC"
                ConfirmationMailer.confirmation(@registration).deliver
                redirect_to "/register/confirmation.html"
            elsif account_type == "TRAINING"
                ConfirmationMailer.notifyTrainingAccount(siteproperties.getRegistarNotificationEmail(),@registration).deliver
                redirect_to "/"
            else
                ConfirmationMailer.notifyNewAccount(siteproperties.getRegistarNotificationEmail(),@registration).deliver
                redirect_to "/register/reviewconfirmation.html"
            end
        else
            msg = "Registration Unsuccessful: "
            @user.errors.keys.each do |key|
                @user.errors[key].each do |reason|
                    flash[key] = " #{reason}"
                end
            end
            redirect_to "/register/error.html"
        end
    end

    # show the user's account/information page
    def show
        @user = @current_user
        if @current_user.nil?
            @page_title = "Systematic Review Data Repository"
        else
            @page_title = "User Profile for " + @current_user.login
        end
    end

    # enable a user to change their profile information.
    # show the edit profile screen
    def edit
        @user = @current_user
        @page_title = "Edit User Profile"
        @editing = true
    end

    # update the user's account information
    def update
        @user = @current_user # makes our views "cleaner" and more consistent
        params[:user][:email].downcase!
        params[:user].delete("user_type")
        if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            redirect_to account_url
        else
            error_string = ""
            @user.errors.each do |key, value|
              error_string += ("#{key } #{value}; ").titleize
            end
            flash.now[:error] = error_string
            render :action => :edit
        end
    end

    def confirmation
        # Destroy session - await validation
        if !current_user_session.nil?
            current_user_session.destroy
        end
        session[:project_id] = nil
        session[:project_title] = nil
        session[:study_id] = nil
    end

    def reviewconfirmation
        # Destroy session - await validation
        if !current_user_session.nil?
            current_user_session.destroy
        end
        session[:project_id] = nil
        session[:project_title] = nil
        session[:study_id] = nil
    end

    def error
    end

    def agreement_error
    end

    def validateuser
        # Validate user account request
        new_userlogin = params["user"]
        validation_code = params["vcode"]
        today = Time.now.utc()
        @registration = Registar.find(:first, :conditions=>["login = ? and validationcode = ? and status = 'VALIDATION'", new_userlogin, validation_code])
        @days_since_registration = -1
        if !@registration.nil?
            @days_since_registration = (today.to_i - @registration.created_at.to_i)/(60 * 60 * 24)
        end
        if @days_since_registration > 2
            # Remove user registration and account - been more than two days since original request, validation expired
            @user = User.find(:first, :conditions=>["login = ? and user_type = 'PENDING'", new_userlogin])
            @user.destroy
            @registration.destroy
        elsif @days_since_registration >= 0
            # Validation within 2 days - complete the registration process
            @user = User.find(:first, :conditions=>["login = ? and user_type = 'PENDING'", new_userlogin])
            @user.user_type = "public"
            @user.updated_at = Time.now
            @user.save
            @registration.status = "APPROVED"
            @registration.updated_at = Time.now
            @registration.save
            @organization = Organization.find(:first, :conditions=>["name = ?", @user.organization])
            if @organization.nil?
                @organization = Organizations.new
                @organization.name = "PUBLIC"
                @organization.description = "Default Public"
                @organization.contact_name = "No Contact"
                @organization.save
            end
            @userorgroles = UserOrganizationRole.find(:first, :conditions=>["user_id = ?",@user.id])
            if @userorgroles.nil?
                @userorgroles = UserOrganizationRole.new
                @userorgroles.user_id = @user.id
            end
            @userorgroles.role = "public"
            @userorgroles.status = "VALID"
            @userorgroles.organization_id = @organization.id
            @userorgroles.updated_at = Time.now
            @userorgroles.save
        end
    end

    def validatecontributor
        # Validate user account request
        new_userlogin = params["user"]
        validation_code = params["vcode"]
        today = Time.now.utc()
        @registration = Registar.find(:first, :conditions=>["login = ? and validationcode = ? and status = 'VALIDATION'", new_userlogin, validation_code])
        @days_since_registration = -1
        if !@registration.nil?
            @days_since_registration = (today.to_i - @registration.created_at.to_i)/(60 * 60 * 24)
        end
        if @days_since_registration > 2
            # Remove user registration and account - been more than two days since original request, validation expired
            @user = User.find(:first, :conditions=>["login = ? and user_type = 'PENDING'", new_userlogin])
            @user.destroy
            @registration.destroy
        elsif @days_since_registration >= 0
            # Validation within 2 days - complete the registration process
            @user = User.find(:first, :conditions=>["login = ? and user_type = 'PENDING'", new_userlogin])
            @user.user_type = "member"
            @user.updated_at = Time.now
            @user.save
            @registration.status = "APPROVED"
            @registration.updated_at = Time.now
            @registration.save
        end
    end

    def email_preferences
      @stale_project_reminders = current_user.find_stale_project_reminders
    end

    def toggle_email_preference
      project_id = params[:project_id]
      if current_user.is_lead(project_id)
        spr = StaleProjectReminder.where(project_id: project_id, user_id: current_user).first
        spr.toggle(:enabled)
        spr.save
      end

      redirect_to '/account/email_preferences'
    end

    def turn_on_all_email_reminders
      current_user.stale_project_reminders.map{ |spr| spr.update_attributes(enabled: true) }

      redirect_to '/account/email_preferences'
    end

    def turn_off_all_email_reminders
      current_user.stale_project_reminders.map{ |spr| spr.update_attributes(enabled: false) }

      redirect_to '/account/email_preferences'
    end
end
