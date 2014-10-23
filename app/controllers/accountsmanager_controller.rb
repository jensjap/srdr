class AccountsmanagerController < ApplicationController
    # Borrowed from SRDR-Admin side - subset of available methods to support SRDR-Dev on Heroku

    def show
    end

    def index
    end

    # delete user account
    def delete
        @user_id = nil
        @user_login = nil
        @user_fname = nil
        @user_lname = nil
        user = User.find(:first, :conditions=>["id = ?",params[:user_id]])
        if !user.nil?
            @user_id = user.id
            @user_login = user.login
            @user_fname = user.fname
            @user_lname = user.lname
            # Clear registration entries for this user
            registration = Registar.find(:first, :conditions=>["login = ?",user.login])
            if !registration.nil?
                registration.destroy
            end
            # Clear user organization role assignments
            uor = UserOrganizationRole.find(:first, :conditions=>["user_id = ?",user.id])
            if !uor.nil?
                uor.destroy
            end
            # Remove the user account
            user.destroy
        end

        # Go back to user list - added to SRDR-Dev only
        redirect_to "/home/user_list"
    end

    # approve user account request
    def approve_request
        puts "............. AccountmanagerController::approve_request "+params[:user_id].to_s
        # Change the user type to be a member of SRDR
        user_id = params[:user_id].to_i
        @user = User.find(:first, :conditions=>["id = ?",user_id])
        @user.user_type = "member"
        @user.save

        # Move the registration status to APPROVED
        @registration = Registar.find(:first, :conditions=>["login = ?",@user.login])
        @registration.status = "APPROVED"
        @registration.save

        # Add Organization if it does not already exist
        @organization = Organizations.find(:first, :conditions=>["name = ?",@user.organization])
        if @organization.nil? &&
            !@user.organization.nil? &&
            (@user.organization.length > 0)
            @organization = Organizations.new
            @organization.name = params["organization"]
            @organization.contact_name = "No Contact"
            @organization.save
        else
            # Set default organization for this user
            @organization = Organizations.new
            @organization.name = "TMC EPC"
            @organization.contact_name = "No Contact"
            @organization.save
        end

        # Now setup the user's organization role
        @userorgroles = UserOrganizationRole.new
        @userorgroles.user_id = @user.id
        @userorgroles.role = "contributor"
        @userorgroles.status = "VALID"
        @userorgroles.organization_id = @organization.id
        @userorgroles.save

        # Send E-mail notification of approval to the user
        #ConfirmationMailer.notifyApproval(@registration).deliver

        # Go back to user list - added to SRDR-Dev only
        redirect_to "/home/user_list"
    end
end
