class ConfirmationMailer < ActionMailer::Base
  default :from => "srdr-admin@ahrq.hhs.gov"

    def confirmation(registration)
        @registration = registration
        #print "User is: #{@registration.login} and the email is #{@registration.email}"
        mail(:to=>@registration.email, :subject=>"SRDR Registration Confirmation.")
    end

    def notifyComment(sendto, user, comment)
        @user = user
        @comment = comment
        mail(:to=>sendto, :subject=>"SRDR Public Comments: "+@user.login)
    end

    def notifyTrainingAccount(sendto, registration)
        @registration = registration
        #print "User is: #{@registration.login} and the email is #{@registration.email}"
        mail(:to=>sendto, :subject=>"New SRDR Training Account Created: "+@registration.login)
    end

    def notifyNewAccount(sendto, registration)
        @registration = registration
        #print "User is: #{@registration.login} and the email is #{@registration.email}"
        mail(:to=>sendto, :subject=>"New SRDR Project Account Request: ["+@registration.organization+"] "+@registration.login)
    end
end
