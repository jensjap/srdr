class AddDescriptionToEfTemplate < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_templates do |t|
  		t.text :description
  	end
  end

  def self.down
  end
end
