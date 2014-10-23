class AddComparisonTable < ActiveRecord::Migration
  def self.up
  	change_table :comparison_measures do |t|
  		t.integer :comparison_id
  	end
  	remove_column(:comparison_data_points, :within_or_between);
  	
  	create_table :comparisons do |t|
  		t.string :within_or_between
  	end
  	
  end

  def self.down
  end
end
