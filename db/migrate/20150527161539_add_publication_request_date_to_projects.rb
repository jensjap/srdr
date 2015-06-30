class AddPublicationRequestDateToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :publication_requested_at, :datetime
  end

  def self.down
    remove_column :projects, :publication_requested_at
  end
end
