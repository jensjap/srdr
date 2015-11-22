class DaaInfoController < ApplicationController
    layout "daa_info_layout"

    def index
    end

    def eligibility
        # Unique identifier for this particular eligibility form.
        # We will reject submitting the same submissionToken twice.
        @submissionToken = create_submission_token
    end

    def not_eligible
    end

    def eligible
        # params
        @trial_participant_info = TrialParticipantInfo.new
        @age                      = params["age"]
        @readEnglish              = params["readEnglish"]
        @experienceExtractingData = params["experienceExtractingData"]
        @experienceLevel          = params["experienceLevel"]
        @articlesExtracted        = params["articlesExtracted"]
        @submissionToken          = params["submissionToken"]

        # Text params to see if any of them disqualify the user.
        if [@age, @readEnglish, @experienceExtractingData, @experienceLevel, @articlesExtracted, @submissionToken].map!(&:blank?).include?(true) ||
            @age == "<20" || @readEnglish == "no" || @experienceExtractingData == "no"
            redirect_to daa_not_eligible_path
            return
        end
    end

    def create
        submissionToken = params["trial_participant_info"]["submissionToken"]
        if submissionToken.blank?
            flash[:error] = "Your submission could not be processed at this time. Please try again later."
        else
            if TrialParticipantInfo.find_by_submissionToken(submissionToken)
                flash[:error] = "You cannot submit again without starting over the form. Please reload the form, fill it out and resubmit your request."
            else
                if is_a_valid_email?(params["trial_participant_info"]["email"])
                    @trial_participant_info = TrialParticipantInfo.new
                    @trial_participant_info.email = params["trial_participant_info"]["email"]
                    @trial_participant_info.age = params["trial_participant_info"]["age"]
                    @trial_participant_info.readEnglish = params["trial_participant_info"]["readEnglish"] == "yes" ? true : false
                    @trial_participant_info.experienceExtractingData = params["trial_participant_info"]["experienceExtractingData"] == "yes" ? true : false
                    @trial_participant_info.experienceLevel = params["trial_participant_info"]["experienceLevel"]
                    @trial_participant_info.articlesExtracted = params["trial_participant_info"]["articlesExtracted"]
                    @trial_participant_info.submissionToken = params["trial_participant_info"]["submissionToken"]

                    if @trial_participant_info.save
                        flash[:success] = "Thank you for your submission."
                    else
                        flash[:error] = "Your submission could not be processed at this time. Please try again later."
                    end
                else
                    flash[:error] = "Invalid email format."
                end
            end
        end

        redirect_to daa_info_path
    end

    def consent
        @consent = DaaConsent.new
        @submission_token = create_submission_token
    end

    def consent_submit
        @consent = DaaConsent.new(params["daa_consent"])
        if @consent.save
            redirect_to daa_thanks_url
        else
            @submission_token = create_submission_token
            flash.now[:error] = "Invalid submission. Please review the form and make sure all fields are filled out."
            flash.now[:specifics] = @consent.errors
            render 'consent'
        end
    end

    def consent_thanks
    end

    private
        def create_submission_token
            timeNow = Time.now
            return (timeNow.hour * 3600 + timeNow.min * 60 + timeNow.sec).to_s
        end

        def is_a_valid_email?(email)
            (email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
        end
end
