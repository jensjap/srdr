class AddRowAndColToEftDbs < ActiveRecord::Migration
  def self.up
  	change_table :eft_design_detail_fields do |t|
  		t.integer :row_number, :default=>0
  		t.integer :column_number, :default=>0
  	end
  	change_table :eft_baseline_characteristic_fields do |t|
  		t.integer :row_number, :default=>0
  		t.integer :column_number, :default=>0
  	end
  end

  def self.down
  end
end
