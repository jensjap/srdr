class CreateCompleteStudySections < ActiveRecord::Migration
  def self.up
  	create_table :complete_study_sections do |t|
  		t.integer :study_id
  		t.integer :extraction_form_id
  		t.integer :flagged_by_user
  		t.boolean :is_complete
  		t.timestamps
  	end
  end

  def self.down
  end
end