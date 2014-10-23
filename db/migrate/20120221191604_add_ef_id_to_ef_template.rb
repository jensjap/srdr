class AddEfIdToEfTemplate < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_templates do |t|
  		t.integer :template_form_id
  	end
  end

  def self.down
  end
end
