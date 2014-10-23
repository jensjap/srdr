class UpdateDataPointValuesToText < ActiveRecord::Migration
  def self.up
  	change_column(:baseline_characteristic_data_points, :value, :text)
  	change_column(:design_detail_data_points, :value, :text)
  end

  def self.down
  end
end
