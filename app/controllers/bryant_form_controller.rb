class BryantFormController < ApplicationController
    layout "bryant_form_layout"

    def form
    end

    def save
        begin
            sqiq = SrdrQualityImprovementQuestionnaire.new(params.except(:utf8,:authenticity_token,
                                                                         :commit,:controller,:action))
            sqiq.save
        rescue
            QuestionnaireMailer.questionnaire_notifier(params).deliver
        end
    end
end
