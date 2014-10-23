class AddMeasureTypeToOutcomeAndComparisonMeasure < ActiveRecord::Migration
  def self.up
  	change_table :outcome_measures do |t|
  		t.integer :measure_type, :default=>0
  	end
  	change_table :comparison_measures do |t|
  		t.integer :measure_type, :default=>0
  	end
  end

  def self.down
  end
end
