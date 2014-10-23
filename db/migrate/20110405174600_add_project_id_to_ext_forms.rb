class AddProjectIdToExtForms < ActiveRecord::Migration
  def self.up
	add_column :extraction_forms, :project_id, :integer
  end

  def self.down
	remove_column :extraction_forms, :project_id
  end
end
