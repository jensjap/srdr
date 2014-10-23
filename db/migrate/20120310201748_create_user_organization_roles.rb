class CreateUserOrganizationRoles < ActiveRecord::Migration
  def self.up
    create_table :user_organization_roles do |t|
      t.integer :user_id
      t.string :role
      t.string :status
      t.boolean :notify
      t.boolean :add_internal_comments
      t.boolean :view_internal_comments
      t.boolean :publish
      t.boolean :certified

      t.timestamps
    end
  end

  def self.down
    drop_table :user_organization_roles
  end
end
