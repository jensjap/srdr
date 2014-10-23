class AddWithinOrBetweenToDefaultComparisonMeasures < ActiveRecord::Migration
  def self.up
  	change_table :default_comparison_measures do |t|
  		t.integer :within_or_between, :default=>0
  	end
  end

  def self.down
  end
end
