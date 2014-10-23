# == Schema Information
#
# Table name: user_organization_roles
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  role                   :string(255)
#  status                 :string(255)
#  notify                 :boolean
#  add_internal_comments  :boolean
#  view_internal_comments :boolean
#  publish                :boolean
#  certified              :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  organization_id        :integer
#

  # This class links users to projects. A User can be either an admin (username 'admin' only), a project lead, or a project editor.
  #
  # A user becomes a project lead currently (as of 1/2012) by simply creating a new project in the system. A project lead has
  # the ability to create extraction forms and studies. A project lead can also assign users to their projects.
  #
  # A user becomes a project editor or collaborator when the project lead adds them via the project user management page. A
  # project editor/collaborator has the ability to create new studies within a project using existing extraction forms, and edit study data.
  class UserOrganizationRole < ActiveRecord::Base
    belongs_to :organizations
    belongs_to :user

    # get the user's full role name
    # @return [string]
    def get_full_role
      if role == "admin"
        return "Administrator"
      elsif role == "lead"
        return "Organization Lead"
      end
    end

    # Remove any entries in the user_project_roles table for the project being deleted.
    # @param [integer] project_id
    def self.remove_roles_for_organization(organization_id)
      roles = UserOrganizationRole.where(:organization_id => organization_id)
      unless roles.empty?
        roles.each do |role_entry|
          role_entry.destroy
        end
      end
    end


  end

