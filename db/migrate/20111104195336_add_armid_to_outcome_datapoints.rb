class AddArmidToOutcomeDatapoints < ActiveRecord::Migration
  def self.up
  	change_table :outcome_data_points do |t|
  		t.integer :arm_id
  	end
  end

  def self.down
  end
end
