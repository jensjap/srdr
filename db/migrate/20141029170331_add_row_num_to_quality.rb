class AddRowNumToQuality < ActiveRecord::Migration
  def self.up
    add_column :quality_dimension_fields, :question_number, :integer
  end

  def self.down
    remove_column :quality_dimension_fields, :question_number
  end
end
