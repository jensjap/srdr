class CreateExtractionFormTemplatesTable < ActiveRecord::Migration
  def self.up
  	create_table :extraction_form_templates do |t|
  		t.string :title
  		t.integer :creator_id
  		t.text :notes
  		t.boolean :adverse_event_display_arms
  		t.boolean :adverse_event_display_total
  		t.boolean :show_to_local
  		t.boolean :show_to_world
  	end
  end

  def self.down
  end
end
