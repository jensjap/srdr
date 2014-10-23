class AddDisplayNumberToOutcomeDataEntry < ActiveRecord::Migration
  def self.up
  	change_table :outcome_data_entries do |t|
  		t.integer :display_number
  	end
  end

  def self.down
  end
end
