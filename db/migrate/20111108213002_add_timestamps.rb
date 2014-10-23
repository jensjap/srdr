class AddTimestamps < ActiveRecord::Migration
  def self.up
  	# first cover the outcome result tables
  	change_table :outcome_data_entries do |t|
  		t.timestamps
  	end
  	change_table :outcome_measures do |t|
  		t.timestamps
  	end
  	change_table :outcome_data_points do |t|
  		t.timestamps
  	end
  	
  	# now the comparison tables
  	change_table :comparisons do |t|
  		t.timestamps
  	end
  	change_table :comparators do |t|
  		t.timestamps
  	end
  end

  def self.down
  end
end
