class SetupMatrixQuestions < ActiveRecord::Migration
  def self.up
  	add_column(:design_details, :is_matrix, :boolean, :default=>false)
  	add_column(:baseline_characteristics, :is_matrix, :boolean, :default=>false)
  	add_column(:design_detail_fields, :column_number, :integer, :default=>0)
  	add_column(:baseline_characteristic_fields, :column_number, :integer, :default=>0)
  end

  def self.down
  end
end
