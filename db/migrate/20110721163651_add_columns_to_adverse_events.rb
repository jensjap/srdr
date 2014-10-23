class AddColumnsToAdverseEvents < ActiveRecord::Migration
  def self.up
	add_column :adverse_events, :arm_id, :integer
	add_column :adverse_events, :is_total_col, :boolean
  end

  def self.down
	remove_column :adverse_events, :arm_id
	remove_column :adverse_events, :is_total_col
  end
end
