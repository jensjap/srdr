class MoveIntentionToTreatToArms < ActiveRecord::Migration
  def self.up
  	remove_column :outcomes, :is_intention_to_treat
  	add_column :arms, :is_intention_to_treat, :boolean, :default=>true
  end

  def self.down
  end
end
