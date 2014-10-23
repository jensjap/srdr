class AddEfidToComparisons < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :extraction_form_id		
  	end
  end

  def self.down
  end
end
