class CreateRegistryUsages < ActiveRecord::Migration
  def self.up
    create_table :registry_usages do |t|
      t.string :requestor_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :registry_usages
  end
end
