class AddFollowUpQuestionOneToTrialParticipantInfo < ActiveRecord::Migration
  def self.up
    add_column :trial_participant_infos, :followUpQuestionOne, :text
  end

  def self.down
    remove_column :trial_participant_infos, :followUpQuestionOne
  end
end
