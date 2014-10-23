class ChangeTimepointNumberToString < ActiveRecord::Migration
  def self.up
  	change_column :outcome_timepoints, :number, :string
  end

  def self.down
  end
end
