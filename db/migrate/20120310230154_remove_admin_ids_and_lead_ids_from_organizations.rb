class RemoveAdminIdsAndLeadIdsFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :admin_ids
    remove_column :organizations, :lead_ids
  end

  def self.down
    add_column :organizations, :lead_ids, :string
    add_column :organizations, :admin_ids, :string
  end
end
