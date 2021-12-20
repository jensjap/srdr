class ServiceTerminationMailer < ActionMailer::Base
  default from: "jens_jap@brown.edu"

  def send_notification(user)
    @subject = 'Notice: The SRDR Website is being Decommissioned on January 7, 2022, Here are steps you can take to retain access to your Unpublished SRDR Projects'
    @user    = user
    puts "  Sending email to: " + user.email
    mail(to: user.email, subject: @subject)
  end
end
