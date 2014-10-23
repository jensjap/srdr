class CreateEfSectionCopies < ActiveRecord::Migration
  def self.up
  	create_table :extraction_form_section_copies do |t|
  		t.string :section_name
  		t.integer :copied_from
  		t.integer :copied_to
  		t.timestamps
  	end
  end

  def self.down
  end
end
