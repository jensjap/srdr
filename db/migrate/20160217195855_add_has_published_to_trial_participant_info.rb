class AddHasPublishedToTrialParticipantInfo < ActiveRecord::Migration
  def self.up
    add_column :trial_participant_infos, :hasPublished, :boolean
  end

  def self.down
    remove_column :trial_participant_infos, :hasPublished
  end
end
