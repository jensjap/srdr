class CreateAddTypeToRoles < ActiveRecord::Migration
  def self.up
    create_table :add_type_to_roles do |t|
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :add_type_to_roles
  end
end
