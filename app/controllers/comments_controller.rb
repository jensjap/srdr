# The comments controller contains methods for creating, updating, deleting and
# replying to individual comments. It also contains methods for opening the comment
# summary dialog windows found on Project Summary and My Work pages.
#
class CommentsController < ApplicationController
before_filter :require_user, :except => [:show, :sort, :show_summary]

	# save a newly created comment
	# this method contains commented deprecated code that was used to determine whether to "post comment" or "post and email user"
	# and send an email based on the user's choice.
  def create
	@value_at_comment_time = params[:comment][:value_at_comment_time]    
	@section_id = params[:comment][:section_id]
	@section_name = params[:comment][:section_name]
	@field_name = params[:comment][:field_name]
	@page_name = params[:comment][:page_name]
	@project_id = params[:comment][:project_id]
	@study_id = params[:comment][:study_id]
	@is_flag = params[:comment][:is_flag]
	@extraction_form_id = params[:comment][:extraction_form_id]	
	
    # This method is called from boty [Post a Comment] and [Flag This Data Item] 
    # If adding a comment flag - allow for empty comment
    @checked_comm_text = params[:comment][:comment_text]
    if (@is_flag == "true") &&
       (@checked_comm_text.nil? || (@checked_comm_text == ""))
        @checked_comm_text = "VALID EMPTY"
    end
	if !@checked_comm_text.nil? && (@checked_comm_text != "")
		@comment = Comment.new(params[:comment])	
		if @study_id == ""
			@study_id = -1
		end
        # If flag without a comment, use a place holder
        if (@checked_comm_text == "VALID EMPTY")
            @comment.comment_text = "-"
        end
        # Check and nill unselected values
        if !@comment.flag_type.nil? &&
            (@comment.flag_type == "SELECT")
            @comment.flag_type = ""
        end
        # Check and nill unselected values
        if !@comment.fact_or_opinion.nil? &&
            (@comment.fact_or_opinion == "SELECT")
            @comment.fact_or_opinion = ""
        end
        
        # MK Mark comment status in post_type
        post_user = User.find(current_user.id)
        if post_user.user_type == "public"
            @comment.post_type = "PENDING"
        else
            # Non-public commentors are automatically reviewed and posted
            @comment.post_type = "REVIEWED"
        end
        
        # save comment
		@comment.study_id = @study_id
		@saved = @comment.save
    puts "-------------------------- comments_controller::create - @saved = "+@saved.to_s
    
    if post_user.user_type == "public"
        # Now send an E-mail to admin notifying a public comment has been posted
        # Get site properties
        siteproperties = session[:guiproperties]
        if siteproperties.nil?
            siteproperties = Guiproperties.new
            session[:guiproperties] = siteproperties
        end

        puts ".......... now get user via id "+ current_user.id.to_s
        @user = User.find(:first,:conditions=>["id = ?", current_user.id.to_s])
        if @user.nil?
            puts "............ cannot locate user"
        else
            puts "............ found user login "+@user.login
        end
        ConfirmationMailer.notifyComment(siteproperties.getCommentsNotificationEmail(), @user, @comment).deliver
    end

	# Below is the code to choose whether to "post and email user" or just "post" a comment.
	# as of 1-19-2012 this feature is not being used
	#	@how_to_comment = params[:how_to_comment]

	#	if (@how_to_comment == "Post and Email User")
	#		# email user about the comment
	#		# get comment user
	#		# comment is a reply
	#		# get the reply_to comment
	#		@replying_to = Comment.find(params[:comment][:reply_to])
	#		@user_id = @replying_to.commenter_id
	#		@replying_to_commenter = User.find(@user_id)
	#		# get user email address		
	#		@address_to_email = @replying_to_commenter.email	
	#		# construct an email body
	#		# send the mail to the user
	#		UserMailer.reply_posted(@comment, @address_to_email).deliver
	#	end	
		
	#	if (@how_to_comment == "Post and Email Project Leads")
	#		# comment is not a reply
	#		# email project lead
	#		# get the project leads email info
	#		@project_leads_emails = Project.get_project_leads_emails_array(@project_id)
	#		UserMailer.comment_posted(@comment, @project_leads_emails).deliver		
	#		# construct an email body
	#		# send the mail to the user(s)
	#	end

	else
		# comment text is empty - deal with it.
		 flash[:error_message] = "You must enter a comment."
	end
	
	@current_sorting_order = "recent"
	@show_both = User.current_user_is_collaborator(@project_id, current_user)
	@comments = Comment.get_comments_and_flags(@section_name, @section_id, @field_name, @study_id, @project_id, @show_both, @current_sorting_order)	
	render "comments/create.js.erb", :locals => {:comments => @comments, :section_name => @section_name, :section_id => @section_id, :field_name => @field_name, :study_id => @study_id, :value_at_comment_time => @value_at_comment_time, :project_id => @project_id}
end

# re-display comment list based on params[:sort_by]
def sort
	@current_sorting_order = params[:sort_by]
	@section_id = params[:section_id]
	@section_name = params[:section_name]
	@field_name = params[:field_name]
	@study_id = params[:study_id]
	@project_id = params[:project_id]
	@project = Project.find(params[:project_id])
	@show_both = User.current_user_is_collaborator(@project_id, current_user)
	@comments = Comment.get_comments_and_flags(@section_name, @section_id, @field_name, @study_id, @project_id, @show_both, @current_sorting_order)
	render "comments/sort.js.erb", :locals => {:comments => @comments, :section_name => @section_name, :section_id => @section_id, :field_name => @field_name, :study_id => @study_id, :value_at_comment_time => @value_at_comment_time, :project_id => @project_id, :current_sorting_order => @current_sorting_order}		
end


# re-display comment summary based on params[:sort_by]
def summary_sort
	@current_sorting_order = params[:sort_by]
	@project_id = params[:project_id]
	@project = Project.find(params[:project_id])
	@show_both = User.current_user_is_collaborator(@project_id, current_user)
	@comments = Comment.get_project_comments_and_flags(@project_id, @show_both, @current_sorting_order)
	render "comments/summary_sort.js.erb", :locals => {:comments => @comments, :value_at_comment_time => @value_at_comment_time, :project_id => @project_id, :current_sorting_order => @current_sorting_order}		
end

  # can only be used by admin so far - controlled using delete buttons in views/comments/_single_comment.html.erb
  def destroy
    puts "...................... comments_controller::destroy on id "+params[:id].to_s
    @comment = Comment.find(params[:id])
    @comment.destroy
  end
 
  # remove the comment from the list. 
  # after it is removed, refresh the view partial and show the updated list of comments.
  def remove
    @div_id = params[:div_id]
    @div_id_arr = @div_id.split("_")
    @comment_id = @div_id_arr[2]  
    puts "...................... comments_controller::remove on @comment_id "+@comment_id.to_s
    comment = Comment.find(@comment_id)
    @section_name = comment.section_name
    @section_id = comment.section_id
    @field_name = comment.field_name
    @study_id = comment.study_id
    @project_id = comment.project_id
    @value_at_comment_time = comment.value_at_comment_time
    puts "...................... comments_controller::remove found and now removing comment"

    # Only allow the comment owner or admin to destroy
    if comment.commenter_id.eql?(current_user.id) || current_user.is_admin?
     	# delete the note and all associated replies
      if !comment.is_reply
        replies = Comment.where(:is_reply => true, :reply_to=>comment.id).all
        replies.each do |reply|
          reply.destroy
        end
      end
        
      @saved = comment.destroy
    end
    @current_sorting_order = "recent"	
    @show_both = User.current_user_is_collaborator(@project_id, current_user)
    @comments = Comment.get_comments_and_flags(@section_name, @section_id, @field_name, @study_id, @project_id, @show_both, @current_sorting_order)

    render "comments/create.js.erb", :locals => {:comments => @comments, :section_name => @section_name, :section_id => @section_id, :field_name => @field_name, :study_id => @study_id, :value_at_comment_time => @value_at_comment_time, :project_id => @project_id}
  end
  
  # display the form that allows users to enter a reply to a given note
  def show_reply_form
	@value_at_comment_time = params[:value_at_comment_time]    
	@section_name = params[:section_name]
	@section_id = params[:section_id]
	@field_name = params[:field_name]
	@study_id = params[:study_id] 
	@project_id = params[:project_id] 
	@project = Project.find(@project_id)
	@div_id = params[:div_id]
	@div_id_arr = @div_id.split("_")
  	@comment_id = @div_id_arr[2]
	@replying_to = Comment.find(@comment_id)
  	@comment_reply = Comment.new
	render "show_reply_form.js.erb"
  end

	# based on the comment, fetch and redirect_to the URL of the editing page that contains
	# the section the comment was originally added to.
    def go_to_edit_section
		@field_name = params[:div_id]
		field_name_arr = @field_name.split("_")
		@comment_id = field_name_arr[3]
		@comment = Comment.find(@comment_id)
		@url = Comment.get_edit_url(@comment)
		redirect_to @url
		#render "edit_specific.js.erb"		
	end
	
	# based on the comment, fetch and redirect_to the URL of the viewing page that contains
	# the section the comment was originally added to.
    def go_to_view_section
		@field_name = params[:div_id]
		field_name_arr = @field_name.split("_")
		@comment_id = field_name_arr[3]
		@comment = Comment.find(@comment_id)
		@section_name = @comment.section_name
		@section_id = @comment.section_id
		@field_name = @comment.field_name
		@study_id = @comment.study_id
		@project_id = @comment.project_id	
		@url = Comment.get_view_url(@comment)
		@open_study = Comment.get_view_open_study(@comment)
		redirect_to @url
		#render "view_specific.js.erb"
	end	
  
  # show the comment list based on the ID of the button clicked (sent via ajax)
  def show
	@value_at_comment_time = params[:value_at_comment_time]  
	@field_name = params[:div_id]
	# field name format: comments_section_X_id_Y_field_Z_study_Q_project_R
	# X = section_name
	# Y = section_id
	# Z = field_name
	# Q = study_id
	# R = project_id
	field_name_arr = @field_name.split("_")
	@section_name = field_name_arr[2]
	@section_id = field_name_arr[4]
	@field_name = field_name_arr[6]
	@study_id = field_name_arr[8] 
	@project_id = field_name_arr[10] 
	if (@study_id == "-1")
		@study_id = -1
	end
	@current_sorting_order = "recent"
	if defined?(current_user) && !current_user.nil?
		@show_both = User.current_user_is_collaborator(@project_id, current_user)
	else
		@show_both = false
	end
	@comments = Comment.get_comments_and_flags(@section_name, @section_id, @field_name, @study_id, @project_id, @show_both, @current_sorting_order)
	print @comments.to_s
	render :partial => 'comments/thread', :locals => {:comments => @comments, :project_id => @project_id}
  end
  
  # show the comment summary based on the ID of the button clicked (sent via ajax)  
  def show_summary
	@value_at_comment_time = params[:value_at_comment_time]  
	@field_name = params[:div_id]
	field_name_arr = @field_name.split("_")
	@project_id = field_name_arr[2] 
	@current_sorting_order = "recent"
	if defined?(current_user) && !current_user.nil?
		@show_both = User.current_user_is_collaborator(@project_id, current_user)
	else
		@show_both = false
	end
	@comments = Comment.get_project_comments_and_flags(@project_id, @show_both, @current_sorting_order)
	render :partial => 'comments/summary_thread', :locals => {:comments => @comments, :project_id => @project_id}
  end  
  
  # shows the comment form in a dialog window. The dialog type used is qtip2.
  def new
	@value_at_comment_time = params[:value_at_comment_time]    
	@section_name = params[:section_name]
	@section_id = params[:section_id]
	@field_name = params[:field_name]
	@study_id = params[:study_id] 
	@project_id = params[:project_id]
	@project = Project.find(@project_id)	
	if (@study_id == "-1")
		@study_id = nil
	end
	render :partial => 'comments/comment_form', :locals => {:comment => Comment.new, :section_name => @section_name, :section_id => @section_id, :field_name => @field_name, :study_id => @study_id, :project_id => @project_id}
  end  
  
  # opens the form for adding a new flag
  def new_flag
	@value_at_comment_time = params[:value_at_comment_time]    
	@section_name = params[:section_name]
	@section_id = params[:section_id]
	@field_name = params[:field_name]
	@study_id = params[:study_id] 
	@project_id = params[:project_id]
	@project = Project.find(@project_id)	
	if (@study_id == "-1")
		@study_id = nil
	end
	render :partial => 'comments/flag_form', :locals => {:comment => Comment.new, :section_name => @section_name, :section_id => @section_id, :field_name => @field_name, :study_id => @study_id, :project_id => @project_id}
  end    
  
end
