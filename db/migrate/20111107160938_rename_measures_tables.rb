class RenameMeasuresTables < ActiveRecord::Migration
  def self.up
  	rename_table :outcome_measures_bank, :default_outcome_measures
  	rename_table :comparison_measures_bank, :default_comparison_measures
  end

  def self.down
  end
end
