class CreateEfSectionOptions < ActiveRecord::Migration
  def self.up
  	create_table :ef_section_options do |t|
  		t.integer :extraction_form_id, :null=>false
  		t.string   :section
  		t.boolean :by_arm, :default => false
  		t.boolean :by_outcome, :default => false
  		t.boolean :include_total, :default=>false
  	end
  end

  def self.down
  	drop_table :ef_section_options
  end
end
