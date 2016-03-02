class DaaInfoController < ApplicationController
    layout "daa_info_layout"

    def index
    end

    def eligibility
        # Unique identifier for this particular eligibility form.
        # We will reject submitting the same submissionToken twice.
        @submissionToken = _create_submission_token
    end

    def not_eligible
    end

    def eligible
        # params
        @trial_participant_info = TrialParticipantInfo.new
        @age                      = params["age"]
        @readEnglish              = params["readEnglish"]
        @experienceExtractingData = params["experienceExtractingData"]
        @articlesExtracted        = params["articlesExtracted"]
        @hasPublished             = params["hasPublished"]
        @followUpQuestionOne      = params["followUp_question_one"]
        @recentExtraction         = params["recentExtraction"]
        @trainingType             = params["trainingType"]
        @experienceLevel          = params["experienceLevel"]
        @currentStatus            = params["currentStatus"]
        @submissionToken          = params["submissionToken"]

        # Text params to see if any of them disqualify the user.
        if [@age, @readEnglish, @experienceExtractingData,
            @articlesExtracted, @hasPublished, @recentExtraction,
            @trainingType, @experienceLevel, @currentStatus,
            @submissionToken].map!(&:blank?).include?(true) ||
            @age == "<20" || @readEnglish == "no" || @experienceExtractingData == "no"
            redirect_to daa_not_eligible_path
            return
        end
    end

    def create
        @email                    = params["trial_participant_info"]["email"]
        @email_confirmation       = params["trial_participant_info"]["email_confirmation"]
        @age                      = params["trial_participant_info"]["age"]
        @readEnglish              = params["trial_participant_info"]["readEnglish"]
        @experienceExtractingData = params["trial_participant_info"]["experienceExtractingData"]
        @articlesExtracted        = params["trial_participant_info"]["articlesExtracted"]
        @hasPublished             = params["trial_participant_info"]["hasPublished"]
        @followUpQuestionOne      = params["trial_participant_info"]["followUpQuestionOne"]
        @recentExtraction         = params["trial_participant_info"]["recentExtraction"]
        @trainingType             = params["trial_participant_info"]["trainingType"]
        @experienceLevel          = params["trial_participant_info"]["experienceLevel"]
        @currentStatus            = params["trial_participant_info"]["currentStatus"]
        @submissionToken          = params["trial_participant_info"]["submissionToken"]

        if @submissionToken.blank?
            flash[:error] = "Your submission could not be processed at this time. Please try again later."
        else
            if TrialParticipantInfo.find_by_submissionToken(@submissionToken)
                flash[:error] = "It appears you have already submitted this form. You may not submit the same form twice. Please reload the form, fill it out and resubmit your request."
                redirect_to daa_eligibility_path
            else
                @trial_participant_info = TrialParticipantInfo.new
                unless @email == @email_confirmation
                    flash[:error] = "There was a problem with the email and email confirmation. Please ensure they are not empty and match each other."
                    render action: :eligible
                    return
                else
                    if _is_a_valid_email?(params["trial_participant_info"]["email"])
                        @trial_participant_info.email                    = @email
                        @trial_participant_info.age                      = @age
                        @trial_participant_info.readEnglish              = @readEnglish == "yes" ? true : false
                        @trial_participant_info.experienceExtractingData = @experienceExtractingData == "yes" ? true : false
                        @trial_participant_info.articlesExtracted        = @articlesExtracted
                        @trial_participant_info.hasPublished             = @hasPublished
                        @trial_participant_info.followUpQuestionOne      = @followUpQuestionOne
                        @trial_participant_info.recentExtraction         = @recentExtraction
                        @trial_participant_info.trainingType             = @trainingType
                        @trial_participant_info.experienceLevel          = @experienceLevel
                        @trial_participant_info.currentStatus            = @currentStatus
                        @trial_participant_info.submissionToken          = @submissionToken

                        if @trial_participant_info.save
                            flash[:success] = "Thank you for your submission. Please fill out the consent form below."
                            redirect_to daa_consent_path(email: @email)
                        else
                            flash[:error] = @trial_participant_info.errors.map{ |k, v| "#{k}: #{v}" }.join(", ")
                            render action: :eligible
                            return
                        end
                    else
                        flash[:error] = "Invalid email format."
                        render action: :eligible
                        return
                    end
                end
            end
        end
    end

    def consent
        @email = params[:email]
        @consent = DaaConsent.new
        @submission_token = _create_submission_token + "_" + Digest::MD5.hexdigest(@email.to_s)
    end

    def consent_submit
        daa_consent_info = params[:daa_consent]
        # Apparently unanswered radio buttons are not carried in the params hash.
        # We need to add it manually.
        if params[:daa_consent][:qOne].blank?
            daa_consent_info.merge!(qOne: "")
        end
        if params[:daa_consent][:qTwo].blank?
            daa_consent_info.merge!(qTwo: "")
        end
        @email = daa_consent_info[:email]
        # First determine whether we have an eligibility record for this email on record.
        if _is_user_eligible_by_email?(@email)
            # If eligibility is on record then find or create consent record.
            @consent = DaaConsent.find_or_create_by_email(daa_consent_info[:email])
            @submission_token = @consent.submissionToken || _create_submission_token + "_" + Digest::MD5.hexdigest(@email.to_s)
            @consent.attempt += 1
            @consent.update_attributes(daa_consent_info)
            # Check that @consent object is valid.
            if @consent.valid?
                if _has_wrong_answer?(daa_consent_info)
                    flash[:info] = "You've answered at least one question incorrectly on page 8. Please review the
                                    material and make corrections before re-submitting the form."
                    @targetpage = 1
                else
                    redirect_to daa_thanks_url(daa_consent_info: daa_consent_info)
                    return
                end
            else
                @email = params[:daa_consent][:email]
                @submission_token = _create_submission_token + "_" + Digest::MD5.hexdigest(@email.to_s)
                flash.now[:error] = "Invalid submission. Please review the form and make sure all fields are filled out."
                flash.now[:specifics] = @consent.errors
                if flash[:specifics].present?
                    if flash[:specifics][:qOne].present? || flash[:specifics][:qTwo].present?
                        @targetpage = 8
                    else
                        @targetpage = 10
                    end
                end
            end
            @consent = DaaConsent.new(daa_consent_info)
            render 'consent'
            return
        else
            # Else we send them to the eligibility page with a flash message.
            _handle_user_without_eligible_record
        end
    end

    def consent_thanks
        @first_name      = params[:daa_consent_info][:firstName]
        @last_name       = params[:daa_consent_info][:lastName]
        @email           = params[:daa_consent_info][:email]
        @consent_given   = params[:daa_consent_info][:agree] == 'true' ? true : false
        @submissionToken = params[:daa_consent_info][:submissionToken]
        # Need to create a consent form that the user can download and also email the user and Ian.
        flash[:success] = "Thank you for your submission."
        DaaMailer.daa_consent(token: @submissionToken, email: @email).deliver
    end

    def consent_form
        @token       = params[:token]
        @daa_consent = DaaConsent.find_by_submissionToken(@token)
        if @daa_consent
            filename     = 'DAA Consent - ' + [@daa_consent.firstName, @daa_consent.lastName].join(' ')
            respond_to do |format|
                format.pdf do
                    render pdf:          filename,
                           disposition:  'attachment',
                           show_as_html: params.key?('debug'),
                           template:     'daa_info/consent_form.pdf.erb',
                           layout:       'layouts/pdf.html',
                           save_to_file: Rails.root.join('public/consent_forms', "#{filename}.pdf")
                end
            end
        else
            respond_to do |format|
                format.pdf do
                    render inline: 'Invalid'
                end
            end
        end
    end

    private
        def _create_submission_token
            timeNow = Time.now
            return (timeNow.hour * 3600 + timeNow.min * 60 + timeNow.sec).to_s
        end

        def _is_a_valid_email?(email)
            (email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
        end

        def _is_user_eligible_by_email?(email)
            trial_participant_info = TrialParticipantInfo.find_by_email(email)
            return trial_participant_info.present? ? true : false
        end

        #def _handle_user_with_eligible_record(daa_consent_info)
        #end

        def _handle_user_without_eligible_record
            flash[:error] = "We cannot find an eligibility record for the email you've provided.
                             Please complete the following form to ensure you are eligible for
                             this study."
            redirect_to daa_eligibility_path
        end

        def _has_wrong_answer?(daa_consent_info)
            if daa_consent_info[:qOne] == "Systematic Review Data Repository (SRDR)" && daa_consent_info[:qTwo] == "False"
                return false
            else
                return true
            end
        end
end

