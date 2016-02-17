class AddRecentExtractionToTrialParticipantInfo < ActiveRecord::Migration
  def self.up
    add_column :trial_participant_infos, :recentExtraction, :text
  end

  def self.down
    remove_column :trial_participant_infos, :recentExtraction
  end
end
