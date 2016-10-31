class AddLoginToRegistryUsage < ActiveRecord::Migration
  def self.up
    add_column :registry_usages, :login, :string
  end

  def self.down
    remove_column :registry_usages, :login
  end
end
