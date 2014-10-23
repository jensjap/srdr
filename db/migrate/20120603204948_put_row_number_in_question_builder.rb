class PutRowNumberInQuestionBuilder < ActiveRecord::Migration
  def self.up
  	add_column(:design_detail_fields, :row_number, :integer, :default=>0)
  	add_column(:baseline_characteristic_fields, :row_number, :integer, :default=>0)
  end

  def self.down
  end
end
