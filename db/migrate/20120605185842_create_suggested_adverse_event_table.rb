class CreateSuggestedAdverseEventTable < ActiveRecord::Migration
  def self.up
  	create_table :extraction_form_adverse_events do |t|
  		t.string :title
  		t.text :description
  		t.string :note
  		t.integer :extraction_form_id
  	end
  end

  def self.down
  end
end
