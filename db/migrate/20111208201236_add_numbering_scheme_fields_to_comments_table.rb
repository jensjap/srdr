class AddNumberingSchemeFieldsToCommentsTable < ActiveRecord::Migration
  def self.up
	add_column :comments, :section_name, :string
	add_column :comments, :section_id, :integer
	add_column :comments, :field_name, :string
	add_column :comments, :study_id, :integer
	remove_column :comments, :item_table
	remove_column :comments, :item_id
  end

  def self.down
	remove_column :comments, :section_name
	remove_column :comments, :section_id
	remove_column :comments, :field_name
	remove_column :comments, :study_id
	add_column :comments, :item_table, :string
	add_column :comments, :item_id, :integer
  end
end
