class AddToUserOrganizationRoles < ActiveRecord::Migration
  def self.up
    	change_table :user_organization_roles do |t|
  		t.integer :organization_id
  	end
  end

  def self.down
  end
end
