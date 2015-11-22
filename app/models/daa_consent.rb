class DaaConsent < ActiveRecord::Base
    before_save { email.downcase! }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    validates :email, presence:   true,
                      format:     { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    validates :firstName, presence: true
    validates :lastName, presence: true
    validates :qOne, presence: true
    validates :qTwo, presence: true
    validates :agree, presence: true
    validates :submissionToken, presence: true
end
