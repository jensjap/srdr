class ChangeComparisonColumns < ActiveRecord::Migration
  def self.up
  	remove_column :comparisons, :comparators
  	create_table :comparators do |t|
  		t.integer :comparison_id
  		t.string :comparator
  	end
  	change_table :comparison_data_points do |t|
  		t.integer :comparator_id
  	end
  end

  def self.down
  end
end
