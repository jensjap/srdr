class AddTimestampsToEfTemplates < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_templates do |eft|
  		eft.timestamps
  	end
  end

  def self.down
  end
end
