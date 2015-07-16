class AddDoiIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :doi_id, :string
  end

  def self.down
    remove_column :projects, :doi_id
  end
end
