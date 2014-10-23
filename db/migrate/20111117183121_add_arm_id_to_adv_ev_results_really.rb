class AddArmIdToAdvEvResultsReally < ActiveRecord::Migration
  def self.up
  	add_column :adverse_event_results, :arm_id, :integer
  	remove_column :adverse_event_columns, :arm_id  	
  end

  def self.down
  	remove_column :adverse_event_results, :arm_id 
  	add_column :adverse_event_columns, :arm_id, :integer	
  end
end
