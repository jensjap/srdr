class DaaMailer < ActionMailer::Base
    default :from => "donotreply@daa.com"

    def daa_consent(params)
        @token      = params[:token]
        @email      = params[:email]
        @daaConsent = DaaConsent.find_by_submissionToken(@token)
        @firstName  = @daaConsent.firstName
        @lastName   = @daaConsent.lastName
        mail(to: [@email, "jens_jap@brown.edu", "isaldan1@jhmi.edu"], subject: "New DAA Consent!")
    end
end
