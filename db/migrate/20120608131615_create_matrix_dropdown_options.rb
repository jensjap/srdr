class CreateMatrixDropdownOptions < ActiveRecord::Migration
  def self.up
  	create_table :matrix_dropdown_options do |t|
  		t.integer :row_id
  		t.integer :column_id
  		t.integer :option_text
  	end
  end

  def self.down
  end
end
