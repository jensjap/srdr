class AddCurrentStatusToTrialParticipantInfo < ActiveRecord::Migration
  def self.up
    add_column :trial_participant_infos, :currentStatus, :text
  end

  def self.down
    remove_column :trial_participant_infos, :currentStatus
  end
end
