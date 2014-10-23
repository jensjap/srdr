class AddFootnoteNumberToOutcomeDatapoints < ActiveRecord::Migration
  def self.up
  	change_table :outcome_data_points do |t|
  		t.integer :footnote_number, :default=>0
  	end
  	change_table :comparison_data_points do |t|
  		t.integer :footnote_number, :default=>0
  	end
  end

  def self.down
  end
end
