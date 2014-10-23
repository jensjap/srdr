class AddArmIdToComparisonDataPointTable < ActiveRecord::Migration
  def self.up
  	add_column :comparison_data_points, :arm_id, :integer, :default=>0
  end

  def self.down
  end
end
