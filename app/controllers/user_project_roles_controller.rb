# This controller handles creation and updating of links of users to projects. 
# A User can be either an admin (username 'admin' only), a project lead, or a project editor.
#
# A user becomes a project lead currently (as of 1/2012) by simply creating a new project in the system. A project lead has
# the ability to create extraction forms and studies. A project lead can also assign users to their projects.
#
# A user becomes a project editor or collaborator when the project lead adds them via the project user management page. A 
# project editor/collaborator has the ability to create new studies within a project using existing extraction forms, and edit study data.
class UserProjectRolesController < ApplicationController
before_filter :require_user
 
 # add a user to a systematic review project
 def add_new_user
	if !params["new_user"].nil?
		new_user = params["new_user"]
		uname_exists = User.username_exists(new_user)
		email_exists = User.email_exists(new_user)
		project = Project.find(params[:project_id])
		if !uname_exists && !email_exists
			#redirect - no username or email exists
			the_notice = "A user with that information does not exist. Please contact that person and have them register with SRDR before adding them to this project."
		elsif uname_exists
			unless new_user == current_user.login
				@user = User.where(:login => new_user).first
				@upr = UserProjectRole.new
				@upr.user_id = @user.id
				@upr.project_id = params[:project_id]
				@upr.role = params[:new_role]
				@upr.save
				ProjectCopyRequest.mark_completed(@user.id, project.parent_id, project.id)
				the_notice = "User added successfully."		
			else
				the_notice = "You may not assign yourself to additional project roles."
			end
		elsif email_exists
			unless new_user == current_user.email
				@user = User.where(:email => new_user).first
				@upr = UserProjectRole.new
				@upr.user_id = @user.id
				@upr.project_id = params[:project_id]
				@upr.role = params[:new_role]
				@upr.save
				ProjectCopyRequest.mark_completed(@user.id, project.parent_id, project.id)
				the_notice = "User added successfully."
			else
				the_notice = "You may not assign yourself to additional project roles."
			end
		end
	end
	
	redirect_to '/projects/' + params[:project_id].to_s + '/manage', :notice => the_notice

 end
 
  # save a user's project role
  def saveinfo
	  project_id = params["project_id"]
	  puts "------ saving collaborator table -----\n"
	  params.keys.each do |key|

		key_parts = key.split("_")
		if key_parts[0] == "roles"
			
			num = key_parts[1].to_i
			# num is user_id
			# project_id is project id
			@role = UserProjectRole.where(:user_id => num, :project_id => project_id)
			# if the number of roles for this user is greater than one then that means we erroneously
			# duplicated this information in the past. Remove all duplicates and update the record
			if @role.empty? 
				UserProjectRole.create(:user_id=>num, :project_id=>project_id, :role=>params[key]) unless params[key] == 'delete'
			elsif @role.length > 1
				UserProjectRole.destroy(@role.collect{|x| x.id})
				UserProjectRole.create(:user_id=>num, :project_id=>project_id, :role=>params[key]) unless params[key] == 'delete'
			else
				unless params[key] == 'delete'
					role = @role.first
					role.role = params[key]
					role.save
				else
					UserProjectRole.destroy(@role.first.id)
				end
			end
		end	
	  end
	  the_notice = "Changes saved."
	  redirect_to '/projects/' + params[:project_id].to_s + '/manage', :notice => the_notice
  end

end
