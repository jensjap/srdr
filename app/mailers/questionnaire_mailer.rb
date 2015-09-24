class QuestionnaireMailer < ActionMailer::Base
  default :from => "from@example.com"

  def questionnaire_notifier(params)
    @params = params
    mail(to: "srdr@ahrq.hhs.gov", subject: "testing questionnaire notifier")
  end
end
