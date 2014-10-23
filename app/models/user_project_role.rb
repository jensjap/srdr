# == Schema Information
#
# Table name: user_project_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# This class links users to projects. A User can be either an admin (username 'admin' only), a project lead, or a project editor.
#
# A user becomes a project lead currently (as of 1/2012) by simply creating a new project in the system. A project lead has
# the ability to create extraction forms and studies. A project lead can also assign users to their projects.
#
# A user becomes a project editor or collaborator when the project lead adds them via the project user management page. A 
# project editor/collaborator has the ability to create new studies within a project using existing extraction forms, and edit study data.
class UserProjectRole < ActiveRecord::Base
	belongs_to :project, :touch=>true
	belongs_to :user
	
	# get the user's full role name
	# @return [string]
	def get_full_role
		if role == "lead"
			return "Project Lead"
		elsif role == "editor"
			return "editor"
		end
	end
	
	# set up a hash consisting of role names and user ids based on an existing list of user-project roles
	# @param [array] user_project_role_list
	# @return [hash]
	def self.set_up_role_hash(user_project_role_list)
		the_hash = Hash.new
		if !user_project_role_list.nil?
			for i in user_project_role_list
				the_hash["editor_" + i.user_id.to_s] = i.role + "_" + i.user_id.to_s
				the_hash["lead_" + i.user_id.to_s] = i.role + "_" + i.user_id.to_s
				the_hash["delete_" + i.user_id.to_s] = i.role + "_" + i.user_id.to_s
			end
		end
		return the_hash
	end
	
	# Remove any entries in the user_project_roles table for the project being deleted.
	# @param [integer] project_id
	def self.remove_roles_for_project(project_id)
		roles = UserProjectRole.where(:project_id => project_id)
		unless roles.empty?
			roles.each do |role_entry|
				role_entry.destroy
			end
		end
	end
	
	
end
