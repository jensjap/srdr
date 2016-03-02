class AddAttemptToDaaConsent < ActiveRecord::Migration
  def self.up
    add_column :daa_consents, :attempt, :integer, default: 0
  end

  def self.down
    remove_column :daa_consents, :attempt
  end
end
