class AddSectionIdToCompleteStudySections < ActiveRecord::Migration
  def self.up
  	change_table :complete_study_sections do |t|
  		t.string :section_name
  	end
  end

  def self.down
  end
end
