class AddRowAndColumnToDataPoints < ActiveRecord::Migration
  def self.up
  	add_column(:design_detail_data_points, :row_field_id, :integer, :default=>0)
  	add_column(:baseline_characteristic_data_points, :row_field_id, :integer, :default=>0)
  	add_column(:design_detail_data_points, :column_field_id, :integer, :default=>0)
  	add_column(:baseline_characteristic_data_points, :column_field_id, :integer, :default=>0)
  end

  def self.down
  end
end
