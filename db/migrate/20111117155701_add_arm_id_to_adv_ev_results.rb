class AddArmIdToAdvEvResults < ActiveRecord::Migration
  def self.up
  	add_column :adverse_event_columns, :arm_id, :integer
  end

  def self.down
  	remove_column :adverse_event_columns, :arm_id  
  end
end
