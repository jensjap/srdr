class UpdateComparisons < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :study_id
  		t.string :comparators
  	end
  	
  	drop_table :comparators
  end

  def self.down
  end
end
