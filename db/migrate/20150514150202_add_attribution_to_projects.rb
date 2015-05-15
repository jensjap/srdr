class AddAttributionToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :parent_id, :integer
    add_column :projects, :attribution, :text
  end

  def self.down
  end
end
