class FixArmDetailDataPointTable < ActiveRecord::Migration
  def self.up
  	rename_column :arm_detail_data_points, :baseline_characteristic_field_id, :arm_detail_field_id
  end

  def self.down
  end
end
