class AddGroupIdToAdverseEvents < ActiveRecord::Migration
  def self.up
	add_column :adverse_events, :first_id_in_group, :integer
  end

  def self.down
	remove_column :adverse_events, :first_id_in_group
  end
end
