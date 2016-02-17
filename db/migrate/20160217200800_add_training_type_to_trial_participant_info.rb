class AddTrainingTypeToTrialParticipantInfo < ActiveRecord::Migration
  def self.up
    add_column :trial_participant_infos, :trainingType, :text
  end

  def self.down
    remove_column :trial_participant_infos, :trainingType
  end
end
