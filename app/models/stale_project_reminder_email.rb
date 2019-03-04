class StaleProjectReminderEmail < ActionMailer::Base
  DEFAULT_FROM = "Systematic Review Data Repository <SRDR@ahrq.hhs.gov>"
  DEFAULT_REPLY_TO = "SRDR@ahrq.hhs.gov"

  def send_reminder(recipient_email, lsof_project_ids)
    begin
      from DEFAULT_FROM
      reply_to DEFAULT_REPLY_TO
      subject 'You have unfinished SRDR projects.'
      recipients recipient_email
      sent_on Time.now
      @user = User.where(email: recipient_email).first
      @projects = Project.find(lsof_project_ids)
    rescue Exception => e
      puts "ERROR SENDING STALE PROJECT REMINDER: #{e.message}\n#{e.backtrace}\n\n"
    end
  end
end
