# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      not null
#  email              :string(255)      not null
#  fname              :string(255)      not null
#  lname              :string(255)      not null
#  organization       :string(255)      not null
#  user_type          :string(255)      not null
#  crypted_password   :string(255)      not null
#  password_salt      :string(255)      not null
#  persistence_token  :string(255)      not null
#  login_count        :integer          default(0), not null
#  failed_login_count :integer          default(0), not null
#  last_request_at    :datetime
#  current_login_at   :datetime
#  last_login_at      :datetime
#  current_login_ip   :string(255)
#  last_login_ip      :string(255)
#  perishable_token   :string(255)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#

# the user class is linked to the authlogic authentication gem. This enables authentication/login and logout,
# password encryption and password resetting. For more information see: https://github.com/binarylogic/authlogic
# For specifics about setting up authlogic on rails 3, see http://www.dixis.com/?p=352
class User < ActiveRecord::Base
    before_save { email.downcase! }

    acts_as_authentic

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence:   true,
                      format:     { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }

    validates :login, uniqueness: true
    has_many :data_requests
    has_many :projects, :through => :user_project_roles

    # return the string of the users last and first name, and login
    # @return [string] a string in the format of "Firstname Lastname (Login)"
    def to_string
        retVal = "#{self.fname} #{self.lname} (#{self.login})"
        return retVal
    end

    # delivers password reset instructions via authlogic
    def deliver_password_reset_instructions!
        reset_perishable_token!
        Notifier.deliver_password_reset_instructions(self)
    end

    # determine if the user is listed as an editor for the specified project
    def is_editor(project_id)
        roles = UserProjectRole.where(:user_id=>self.id, :project_id=>project_id, :role=>'editor').size
        return roles > 0
    end

    def is_assigned_to_project(project_id)
        roles = UserProjectRole.count(:conditions=>["user_id=? AND project_id=?", self.id, project_id])
        return roles > 0
    end

    # determine if the user is listed as a lead for the specified project
    def is_lead(project_id)
        if self.user_type == 'super-admin'
            #puts "USER IS AN ADMIN"
            return true
        else
            roles = UserProjectRole.count(:conditions=>["user_id=? AND project_id=? AND role=?",self.id, project_id, "lead"])
            #puts "FOUND #{roles} as lead "
            return roles > 0
        end
    end

    # return the current user object, via authlogic
    def self.get_current_user
        return @current_user
    end

    # is_admin?
    # is the user an srdr-admin?
    def is_admin?
        return self.user_type == 'super-admin'
    end

    # get_collaborator_ids
    # Return an array of user ids corresponding to collaborators of the specified user. A
    # collaborator can be defined by someone who has a role on the same project or who belongs
    # to the same EPC team (or outside organization team)
    # @params [integer] user_id          - the ID of the current user
    # @return [array] collaborator_ids   - a list of collaborator IDs
    def self.get_collaborator_ids user_id
        collaborator_ids = Array.new();
        # determine all projects that the current user plays a role in
        projects = UserProjectRole.where(:user_id=>user_id).select("project_id")
        projects = projects.collect{|x| x.project_id}
        unless projects.empty?
            # find all other users who also have a role in that project and return the unique set of IDs
            collaborator_ids = UserProjectRole.where(:project_id=>projects)
            collaborator_ids = collaborator_ids.collect{|x| x.user_id}
            collaborator_ids.uniq!
            collaborator_ids.delete(user_id)
        end
        return collaborator_ids
    end

    # get ids from extraction forms that are available for the specified user to edit
    # @param [integer] uid user id
    # @return [array] extraction form list
    def self.get_available_extraction_form_ids uid
        # get the ones that the user created
        my_extraction_forms = ExtractionForm.where(:creator_id => uid)
        my_extraction_forms = my_extraction_forms.collect{|extraction_form| extraction_form.id}

        # get the ones that are associated with projects the user can edit or leads
        associated = []
        projects = UserProjectRole.where(:user_id=>uid).order("role DESC")
        projects.each do |proj|
            @tmpProj = Project.find(proj.project_id)
            @tmpProj.studies.each do |study|
                extraction_forms = StudyExtractionForm.where(:study_id=>study.id)
                extraction_forms = extraction_forms.collect{|extf| extf.extraction_form_id}
                associated += extraction_forms
            end
        end
        my_extraction_forms += associated
        my_extraction_forms.uniq!
        return my_extraction_forms
    end

    # send an email with password reset instructions, via authlogic
    def deliver_password_reset_instructions!
        reset_perishable_token!
        Notifier.password_reset_instructions(self).deliver
    end

    # test if the username exists
    # @param [string] str string to test
    # @return [boolean]
    def self.username_exists(str)
        result_uname = User.where(:login => str).all
        if !result_uname.nil? && result_uname.length > 0
            return true
        else
            return false
        end
    end

    # test if the email exists
    # @param [string] str string to test
    # @return [boolean]
    def self.email_exists(str)
        result_email = User.where(:email => str).all
        if !result_email.nil? && result_email.length > 0
            return true
        else
            return false
        end
    end

    # test if the user has roles in a specific project
    # @param [string] str string to test
    # @param [integer] project_id
    # @return [boolean]
    def self.user_has_roles(user, project_id)
        roles = UserProjectRole.where(:user_id => user.id, :project_id => project_id).all
        if !roles.nil? && roles.length > 0
            return true
        else
            return false
        end
    end

    # test if the current user has the privileges to edit the project
    # @param [User] user
    # @param [integer] project_id
    # @return [boolean]
    def self.current_user_has_project_edit_privilege(project_id, user)
        retVal = false
        if !user.nil?
            user_id = user.id
            proj_id = project_id.to_i
            if hasAdminRights(user)
                retVal = true
            else
                roles=UserProjectRole.where(:project_id=>proj_id,:user_id=>user_id,:role=>"lead")
                unless roles.empty?
                    retVal = true
                end
            end
        end
        return retVal
    end

    # test if the current user has the privileges to edit the study
    # @param [User] user
    # @param [integer] project_id
    # @return [boolean]
    def self.current_user_has_study_edit_privilege(project_id, user)
        retVal = false
        if !user.nil?
            user_id = user.id
            proj_id = project_id.to_i
            if hasAdminRights(user)
                retVal = true
            else
                roles = UserProjectRole.where(:project_id => proj_id, :user_id => user_id, :role=>["lead","editor"])
                unless roles.empty?
                    retVal = true
                end
            end
        end
        return retVal
    end

    # test if the current user is a collaborator on the specified project
    # @param [User] user
    # @param [integer] project_id
    # @return [boolean]
    def self.current_user_is_collaborator(project_id, user)
        retVal = false
        if !user.nil?
            user_id = user.id
            project_id = project_id.to_i
            roles = UserProjectRole.where(:project_id => project_id, :user_id => user_id)
            unless roles.empty?
                retVal = true
            end
        end
        return retVal
    end

    # test if the current user is an admin
    # @param [User] user
    # @param [integer] project_id
    # @return [boolean]
    def self.current_user_is_admin(project_id, user)
        retVal = false
        if !user.nil?
            if hasAdminRights(user)
                retVal = true
            end
        end
        return retVal
    end

    # determine if the current user is logged in as admin
    def self.is_admin?
        if is_organization_admin? || is_super_admin?
            return true
        else
            return false
        end
    end

    def self.is_organization_admin?
        if self.user_type == "admin"
            return true
        else
            return false
        end
    end

    def is_super_admin?
        if (self.user_type == "super-admin") || ((self.login == "admin") && (self.user_type == "admin"))
            return true
        else
            return false
        end
    end

    def self.checkAdminRights (user_id)
        if User.is_organization_admin2(user) || User.is_super_admin2(user)
            return true
        else
            return false
        end
    end

    def self.hasAdminRights (user)
        if User.isOrganizationAdmin(user) || User.isSuperAdmin(user)
            return true
        else
            return false
        end
    end

    def self.isOrganizationAdmin (user)
        if user.user_type == "admin"
            return true
        else
            return false
        end
    end

    def self.isSuperAdmin (user)
        if (user.user_type == "super-admin") || ((user.login == "admin") && (user.user_type == "admin"))
            return true
        else
            return false
        end
    end

    # test if the current user has the privileges to edit the extraction form
    # @param [User] user
    # @param [integer] extraction_form_id
    # @return [boolean]
    def self.current_user_has_extraction_form_edit_privilege(extraction_form_id, user)
        if !user.nil?
            if hasAdminRights(user)
                return true
            else
                @extraction_form = ExtractionForm.find(extraction_form_id)
                proj_id = @extraction_form.project_id
                roles = UserProjectRole.where(:project_id=>proj_id, :user_id=>user.id)
                roles = roles.collect{|x| x.role}
                if @extraction_form.creator_id == user.id || roles.include?('lead')
                    return true
                else
                    return false
                end
            end
        else
            return false
        end
    end

    # test if the current user has the privileges to create a new project
    # @param [User] user
    # @return [boolean]
    def self.current_user_has_new_project_privilege(user)
        if !user.nil?
            if hasAdminRights(user)
                return true
            elsif user.user_type == "member"
                return true
            else
                return false
            end
        else
            return false
        end
    end

    # get the list of roles that this user is lead for, in UserProjectRole objects
    # @param [User] user
    # @return [array]
    def self.get_user_lead_roles (user)
        roles = UserProjectRole.where(:user_id => user.id, :role => "lead").all
        if !roles.nil? && roles.length > 0
            return roles
        else
            return nil
        end
    end

    # get the list of projects that this user leads, in Project objects
    # @param [User] user
    # @return [array]
    def self.get_user_lead_projects (user)
        #puts "............ user model - get_user_lead_projects user.id "+user.id.to_s
        roles = UserProjectRole.where(:user_id => user.id, :role => "lead").all
        if !roles.nil? && roles.length > 0
            @project_ids = roles.collect{|r| r.project_id}
            return Project.find_all_by_id(@project_ids)
        else
            return nil
        end
    end

    # get the list of roles that this user is editor for, in UserProjectRole objects
    # @param [User] user
    # @return [array]
    def self.get_user_editor_roles (user)
        roles = UserProjectRole.where(:user_id => user.id, :role => "editor").all
        if !roles.nil? && roles.length > 0
            return roles
        else
            return nil
        end
    end

    # get the list of projects that this user can edit (is an editor/collaborator for), in Project objects
    # @param [User] user
    # @return [array]
    def self.get_user_editor_projects (user)
        roles = UserProjectRole.where(:user_id => user.id, :role => "editor").all
        if !roles.nil? && roles.length > 0
            @project_ids = roles.collect{|r| r.project_id}
            return Project.find_all_by_id(@project_ids)
        else
            return nil
        end
    end

    # get the list of user roles on a particular project (other than the current user).
    # for the user management page of a project.
    # @param [integer] project_id
    # @param [User] current_user
    # @return [array] array of user project roles
    def self.get_users_for_project(project_id, current_user)
        users = UserProjectRole.where(:project_id => project_id).all
        new_list = []
        if !users.empty?
            for u in users
                if u.user_id != current_user.id
                    new_list << u unless u.user_id.nil?  # added the unless u.user_id.nil? because somehow a record like that snuck in
                end
            end
        end
        return new_list
    end

    # get the user's first and last name in a string
    # @param [integer] user_id
    # @return [string]
    def self.get_name(user_id)
        user = User.find(user_id, :select=>[:fname, :lname])
        return user.fname + " " + user.lname
    end

    # get the user's email address
    # @param [integer] user_id
    # @return [string]
    def self.get_email(user_id)
        user = User.find(user_id)
        return user.email
    end

    # boolean indicating whether the user account is public
    # @param [User] user
    # @return [string]
    def self.isPublic(user)
        user = User.find(user.id)
        return user.user_type == "public"
    end
end
