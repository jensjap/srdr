class UpdateAdverseEventColumnsTable < ActiveRecord::Migration
  def self.up
  	remove_column :adverse_event_columns, :is_total_col
  	remove_column :adverse_event_columns, :arm_id
  	remove_column :adverse_event_columns, :study_id
  	remove_column :adverse_event_columns, :header
  end

  def self.down
  	add_column :adverse_event_columns, :is_total_col, :boolean
  	add_column :adverse_event_columns, :arm_id, :integer
  	add_column :adverse_event_columns, :study_id, :integer
  	add_column :adverse_event_columns, :header, :text
  end
end
