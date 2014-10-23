class ChangeMatrixOptionTextToString < ActiveRecord::Migration
  def self.up
  	change_column :matrix_dropdown_options, :option_text, :string
  end

  def self.down
  end
end
