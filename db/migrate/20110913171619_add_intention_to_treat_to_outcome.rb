class AddIntentionToTreatToOutcome < ActiveRecord::Migration
  def self.up
  	add_column :outcomes, :is_intention_to_treat, :boolean
  end

  def self.down
  end
end
