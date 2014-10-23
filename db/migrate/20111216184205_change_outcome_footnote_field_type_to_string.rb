class ChangeOutcomeFootnoteFieldTypeToString < ActiveRecord::Migration
  def self.up
  	change_column :comparison_data_points, :footnote, :string
  	change_column :outcome_data_points, :footnote, :string
  end

  def self.down
  end
end
