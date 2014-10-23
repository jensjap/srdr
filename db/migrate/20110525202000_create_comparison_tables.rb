class CreateComparisonTables < ActiveRecord::Migration
  def self.up
  	create_table :comparison_data_points do |t|
  		t.string :value
  		t.string :footnote
  		t.boolean :is_calculated 
  		t.integer :comparison_measure_id
  		t.binary :within_or_between
  	end
  	
  	create_table :comparison_measures do |t|
  		t.string :title
  		t.text :description
  		t.string :unit
  		t.string :note
  	end
  	
  	create_table :comparators do |t|
  		t.integer :comparison_id
  		t.integer :object_id
  	end
  end

  def self.down
  end
end
