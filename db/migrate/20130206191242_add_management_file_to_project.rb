class AddManagementFileToProject < ActiveRecord::Migration
  def self.up
  	add_column :projects, :management_file_url, :string
  end

  def self.down
  	remove_column :projects, :management_file_url
  end
end
