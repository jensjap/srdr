 class Notifier < ActionMailer::Base
 #default_url_options[:host] = "srdr.training.ahrq.gov"  
 
	def password_reset_instructions(user) 
		@edit_password_reset_url = edit_password_reset_url(user.perishable_token)
		from       "Systematic Review Data Repository <nhadar@tuftsmedicalcenter.org>"
		reply_to "nira_hadar@brown.edu"
		subject    "SRDR Password Reset Instructions"
		recipients    user.email  
		sent_on       Time.now
	end  

	# study_upload_complete
	# sends an email to users after a successful upload of a study assignment list. 
	# Also indicates to them how many studies were successfully assigned, and 
	# if there were problems, which lines they occurred on.
	def study_upload_complete(user, num_successful, problem_lines, warning_lines)
		from 			"Systematic Review Data Repository <nhadar@tuftsmedicalcenter.org>"
		reply_to 		"nira_hadar@brown.edu"
		subject 		"Your SRDR Study Upload"
		recipients 		user.email
		sent_on 		Time.now
		@num_successful = num_successful
		@problem_lines = problem_lines
		@warning_lines = warning_lines
	end

end
