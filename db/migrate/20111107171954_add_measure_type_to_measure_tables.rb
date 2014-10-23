class AddMeasureTypeToMeasureTables < ActiveRecord::Migration
  def self.up
  	change_table :default_outcome_measures do |t|
  		t.integer :measure_type, :default=>0
  	end
  	change_table :default_comparison_measures do |t|
  		t.integer :measure_type, :default=>0
  	end
  end

  def self.down
  end
end
