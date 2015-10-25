class AddQ1CanFollowupToSrdrQualityImprovementQuestionnaire < ActiveRecord::Migration
  def self.up
    add_column :srdr_quality_improvement_questionnaires, :q1_can_followup, :text, after: :q1_email
  end

  def self.down
    remove_column :srdr_quality_improvement_questionnaires, :q1_can_followup
  end
end
