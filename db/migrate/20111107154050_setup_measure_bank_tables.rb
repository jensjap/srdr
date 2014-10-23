class SetupMeasureBankTables < ActiveRecord::Migration
  def self.up
  	drop_table :default_outcome_measures
  	create_table :outcome_measures_bank do |t|
  		t.string :outcome_type
  		t.string :title
  		t.string :description
  		t.string :unit
  		t.boolean :is_default, :default=>false
  	end
  	create_table :comparison_measures_bank do |t|
  		t.string :outcome_type
  		t.string :title
  		t.string :description
  		t.string :unit
  		t.boolean :is_default, :default=>false
  	end
  end

  def self.down
  end
end
