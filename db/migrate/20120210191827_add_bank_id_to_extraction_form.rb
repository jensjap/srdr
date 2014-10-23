class AddBankIdToExtractionForm < ActiveRecord::Migration
  def self.up
  	change_table :extraction_forms do |t|
  		t.integer :bank_id
  	end
  end

  def self.down
  end
end
