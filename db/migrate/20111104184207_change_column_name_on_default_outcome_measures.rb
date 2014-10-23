class ChangeColumnNameOnDefaultOutcomeMeasures < ActiveRecord::Migration
  def self.up
  	rename_column :default_outcome_measures, :name, :title
  end

  def self.down
  end
end
