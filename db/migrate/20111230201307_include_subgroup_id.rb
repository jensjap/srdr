class IncludeSubgroupId < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :subgroup_id, :default=>0
  	end
  	change_table :outcome_data_entries do |t|
  		t.integer :subgroup_id, :default=>0
  	end
  end

  def self.down
  end
end
