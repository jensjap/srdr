class CreateOutcomeDataPoints < ActiveRecord::Migration
  def self.up
    create_table :outcome_data_points do |t|
      t.integer :outcome_id
      t.integer :timepoint_id
      t.integer :arm_id
      t.integer :outcome_measure_id
      t.string :value
      t.integer :footnote_id
      t.boolean :is_calculated
      t.integer :n_enrolled

      t.timestamps
    end
  end

  def self.down
    drop_table :outcome_data_points
  end
end
