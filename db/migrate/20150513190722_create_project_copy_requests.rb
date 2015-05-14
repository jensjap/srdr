class CreateProjectCopyRequests < ActiveRecord::Migration
  def self.up
    create_table :project_copy_requests do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :clone_id
      t.boolean :include_forms
      t.boolean :include_studies
      t.boolean :include_data
      t.timestamps
    end
    add_index :project_copy_requests, :user_id
  end

  def self.down
    drop_table :project_copy_requests
  end
end
