class CreateExtractionFormKeyQuestions < ActiveRecord::Migration
  def self.up
    create_table :extraction_form_key_questions do |t|
      t.integer :extraction_form_id
      t.integer :key_question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :extraction_form_key_questions
  end
end
