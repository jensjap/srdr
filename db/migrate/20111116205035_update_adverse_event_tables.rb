class UpdateAdverseEventTables < ActiveRecord::Migration
  def self.up
  	remove_column :adverse_event_results, :notes
  	remove_column :adverse_events, :is_total_col
  	remove_column :adverse_events, :arm_id
  	remove_column :adverse_events, :first_id_in_group
  	add_column :adverse_events, :title, :text  
  	add_column :adverse_events, :description, :text  
  end

  def self.down
  	add_column :adverse_event_results, :notes, :text
  	add_column :adverse_events, :is_total_col, :boolean
  	add_column :adverse_events, :arm_id, :integer
  	add_column :adverse_events, :first_id_in_group, :integer
  	remove_column :adverse_events, :title  
  	remove_column :adverse_events, :description    
  end
end
