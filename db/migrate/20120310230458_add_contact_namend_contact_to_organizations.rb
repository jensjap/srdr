class AddContactNamendContactToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :contact_name, :string
    add_column :organizations, :contact, :string
  end

  def self.down
    remove_column :organizations, :contact
    remove_column :organizations, :contact_name
  end
end
