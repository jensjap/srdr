class UpdateExtractionFormSection < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_sections do |t|
  		t.integer :borrowed_from_efid
  	end
  end

  def self.down
  end
end
