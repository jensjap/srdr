 class Notifier < ActionMailer::Base
  #default_url_options[:host] = "srdr.ahrq.gov"  
  DEFAULT_FROM = "Systematic Review Data Repository <SRDR@ahrq.hhs.gov>"
  DEFAULT_REPLY_TO = "SRDR@ahrq.hhs.gov"
	def password_reset_instructions(user) 
		@edit_password_reset_url = edit_password_reset_url(user.perishable_token)
		from       "Systematic Review Data Repository <SRDR@ahrq.hhs.gov>"
		reply_to "SRDR@ahrq.hhs.gov"
		subject    "SRDR Password Reset Instructions"
		recipients    user.email  
		sent_on       Time.now
	end  

	# study_upload_complete
	# sends an email to users after a successful upload of a study assignment list. 
	# Also indicates to them how many studies were successfully assigned, and 
	# if there were problems, which lines they occurred on.
	def study_upload_complete(user, num_successful, problem_lines, warning_lines)
		begin
			from 			DEFAULT_FROM
			reply_to 		DEFAULT_REPLY_TO
			subject 		"Your SRDR Study Upload"
			recipients 		user.email
			sent_on 		Time.now
			@num_successful = num_successful
			@problem_lines = problem_lines
			@warning_lines = warning_lines
		rescue Exception=>e 
			puts "ERROR SENDING UPLOAD NOTIFICATION: #{e.message}\n#{e.backtrace}\n\n"
		end
	end

    def simple_import_complete(listOf_email_recipients,
                               skipped_rows,
                               listOf_errors_processing_rows,
                               listOf_errors_processing_questions)
        from DEFAULT_FROM
        reply_to "jens_jap@brown.edu"
        subject "Simple Import Report"
        recipients listOf_email_recipients
        sent_on Time.now
        @skipped_rows = skipped_rows
        @listOf_errors_processing_rows = listOf_errors_processing_rows
        @listOf_errors_processing_questions = listOf_errors_processing_questions
    end

	# new_data_request_received
	# sends an email to let project leads know that a new request for data download has been
	# received and should be addressed as soon as possible.
	def new_data_request_notification(project_id)
		begin
      @project = Project.find(project_id)
      lead_ids = UserProjectRole.find(:all, :conditions=>["project_id=? and role=?", project_id, "lead"], :select=>['user_id'])
      lead_ids = lead_ids.empty? ? [] : lead_ids.collect{|x| x.user_id}
      lead_emails = User.find(:all, :conditions=>["id IN (?)",lead_ids], :select=>["email"])
      
      from DEFAULT_FROM
      reply_to DEFAULT_REPLY_TO
      subject "SRDR - New Download Request Received"
      recipients lead_emails.collect{|x| x.email}.join(",")
      sent_on Time.now

		rescue Exception=>e 
      puts "ERROR SENDING REQUEST NOTIFACTION: #{e.message}\n#{e.backtrace}\n\n"
    end
	end

  # new_data_requst_response
  # let a user know that a response was received for one of their data requests
  def new_data_request_response(user_id, project_id)
    begin
      @project = Project.find(project_id)
      user = User.find(user_id)
      from DEFAULT_FROM
      reply_to DEFAULT_REPLY_TO
      subject "SRDR - Update Regarding your Request for Data"
      recipients user.email 
      sent_on Time.now  
    rescue Exception => e
      puts "ERROR SENDING RESPONSE NOTICE: #{e.message}\n#{e.backtrace}\n\n"
    end
  end 
end
