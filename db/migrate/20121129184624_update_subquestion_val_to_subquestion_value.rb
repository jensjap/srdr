class UpdateSubquestionValToSubquestionValue < ActiveRecord::Migration
  def self.up
  	rename_column :baseline_characteristic_data_points, :subquestion_val, :subquestion_value
  	rename_column :arm_detail_data_points, :subquestion_val, :subquestion_value
  end

  def self.down
  	rename_column :baseline_characteristic_data_points, :subquestion_value, :subquestion_val
  	rename_column :arm_detail_data_points, :subquestion_value, :subquestion_val
  end
end
