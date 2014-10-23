class AddOptionNumberToMatrixDropdownOptions < ActiveRecord::Migration
  def self.up
  	change_table :matrix_dropdown_options do |t|
  		t.integer :option_number
  	end
  end

  def self.down
  end
end
