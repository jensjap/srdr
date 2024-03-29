class TrialParticipantInfo < ActiveRecord::Base
    before_save { email.downcase! }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    validates :email, presence:     true,
                      format:       { with: VALID_EMAIL_REGEX },
                      uniqueness:   { case_sensitive: false },
                      confirmation: true
end
