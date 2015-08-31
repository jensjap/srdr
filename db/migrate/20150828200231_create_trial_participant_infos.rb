class CreateTrialParticipantInfos < ActiveRecord::Migration
  def self.up
    create_table :trial_participant_infos do |t|
      t.string  :age
      t.boolean :readEnglish
      t.boolean :experienceExtractingData
      t.string  :experienceLevel
      t.string  :articlesExtracted
      t.string  :email
      t.string  :submissionToken

      t.timestamps
    end
  end

  def self.down
    drop_table :trial_participant_infos
  end
end
