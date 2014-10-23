class AddColumnsToAdverseEventCols < ActiveRecord::Migration
  def self.up
	add_column :adverse_event_columns, :arm_id, :integer
	add_column :adverse_event_columns, :is_total_col, :boolean
  end

  def self.down
	remove_column :adverse_event_columns, :arm_id
	remove_column :adverse_event_columns, :is_total_col
  end
end
