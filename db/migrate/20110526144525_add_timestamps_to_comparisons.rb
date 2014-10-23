class AddTimestampsToComparisons < ActiveRecord::Migration
  def self.up
  	change_table :comparators do |t|
  		t.timestamps
  	end
  	change_table :comparison_data_points do |t|
  		t.timestamps
  	end
  	change_table :comparison_measures do |t|
  		t.timestamps
  	end
  end

  def self.down
  end
end
