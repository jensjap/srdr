class AddProjectIdToRegistryUsage < ActiveRecord::Migration
  def self.up
    add_column :registry_usages, :project_id, :integer
  end

  def self.down
    remove_column :registry_usages, :project_id
  end
end
