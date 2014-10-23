class ModifyOutcomeTables < ActiveRecord::Migration
  def self.up
  	drop_table :outcome_measures
  	drop_table :outcome_data_points
  	
  	create_table :outcome_data_entries do |t|
  		t.integer :outcome_id
  		t.integer :extraction_form_id
  		t.integer :timepoint_id
  		t.integer :study_id
  	end
  	
  	create_table :outcome_measures do |t|
  		t.integer :outcome_data_entry_id
  		t.string :title
  		t.text :description
  		t.string :unit
  		t.string :note
  	end
  	
  	create_table :outcome_data_points do |t|
  		t.integer :outcome_measure_id
  		t.string :value
  		t.text :footnote
  		t.boolean :is_calculated, :default=>false
  	end
  end

  def self.down
  end
end
