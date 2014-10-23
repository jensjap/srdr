class UpdateQualityDimensionToText < ActiveRecord::Migration
  def self.up
  	change_column(:quality_dimension_fields, :title, :text)
  end

  def self.down
  end
end
