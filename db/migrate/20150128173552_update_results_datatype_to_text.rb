class UpdateResultsDatatypeToText < ActiveRecord::Migration
  def self.up
    change_column :outcome_data_points, :value, :text
  end

  def self.down
    change_column :outcome_data_points, :value, :string
  end
end
