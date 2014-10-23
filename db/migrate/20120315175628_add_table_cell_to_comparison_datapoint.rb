class AddTableCellToComparisonDatapoint < ActiveRecord::Migration
  def self.up
  	change_table :comparison_data_points do |t|
  		t.integer :table_cell
  	end
  end

  def self.down
  end
end
