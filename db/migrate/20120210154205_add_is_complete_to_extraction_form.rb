class AddIsCompleteToExtractionForm < ActiveRecord::Migration
  def self.up
  	change_table :extraction_forms do |t|
  		t.boolean :is_ready
  	end
  end

  def self.down
  end
end
