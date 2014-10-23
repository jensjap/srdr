class CreateStudyNoteTable < ActiveRecord::Migration
  def self.up
  	create_table :study_status_notes do |t|
  		t.integer :study_id
  		t.integer :extraction_form_id
  		t.integer :user_id
  		t.text :note
  		t.timestamps
  	end
  end

  def self.down
  end
end
