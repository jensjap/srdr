class UpdateSubquestionFieldSize < ActiveRecord::Migration
  def self.up
  	change_column :design_detail_data_points, :subquestion_value, :text
  	change_column :arm_detail_data_points, :subquestion_value, :text
  	change_column :outcome_detail_data_points, :subquestion_value, :text
  	change_column :baseline_characteristic_data_points, :subquestion_value, :text
  end

  def self.down
  	change_column :design_detail_data_points, :subquestion_value, :string
  	change_column :arm_detail_data_points, :subquestion_value, :string
  	change_column :outcome_detail_data_points, :subquestion_value, :string
  	change_column :baseline_characteristic_data_points, :subquestion_value, :string
  end
end
