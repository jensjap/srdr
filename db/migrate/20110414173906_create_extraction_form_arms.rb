class CreateExtractionFormArms < ActiveRecord::Migration
  def self.up
  	create_table :extraction_form_arms do |t|
  		t.string :name
  		t.text :description
  		t.string :note
  		t.integer :extraction_form_id
  	end
  end

  def self.down
  end
end
