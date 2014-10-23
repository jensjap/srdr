class UserMailer < ActionMailer::Base
  default :from => "cparkin@tuftsmedicalcenter.org"
  
  def self.thank_you_for_feedback(user)
  	@user = user
  	print "User is: #{@user.login} and the email is #{@user.email}"
  	mail(:to=>@user.email, :subject=>"Thank you for your feedback.")
	end

 def reply_posted(comment, email)
	@comment = comment
	@parent_comment = Comment.find(@comment.reply_to)
	@subject = "A reply has been posted to a comment you left on SRDR"
	@poster = User.find(comment.commenter_id)
	@project = Project.find(comment.project_id)
	if comment.study_id != -1
		@study = Study.find(comment.study_id)
		@comment_setup = @comment_setup + "Study: " + @study.title + "\n"
	end
	
	mail(:to=>email, :subject=>@subject)

 end
 
 def comment_posted(comment, emails)
	@comment = comment
	@subject = "A comment has been posted to your SRDR project"
	@poster = User.find(comment.commenter_id)
	@project = Project.find(comment.project_id)
	if comment.study_id != -1
		@study = Study.find(comment.study_id)
		@comment_setup = @comment_setup + "Study: " + @study.title + "\n"
	end
	
	for one_email in emails
		mail(:to=>one_email, :subject=>@subject)
	end
 end
	
end
