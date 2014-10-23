class AddOutcomeIdToComparison < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :outcome_id
  	end
  end

  def self.down
  end
end
