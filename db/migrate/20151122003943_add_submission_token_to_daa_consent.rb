class AddSubmissionTokenToDaaConsent < ActiveRecord::Migration
  def self.up
    add_column :daa_consents, :submissionToken, :string
  end

  def self.down
    remove_column :daa_consents, :submissionToken
  end
end
