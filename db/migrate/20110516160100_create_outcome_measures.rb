class CreateOutcomeMeasures < ActiveRecord::Migration
  def self.up
    create_table :outcome_measures do |t|
      t.integer :outcome_id
      t.string :measure_name
      t.string :unit
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :outcome_measures
  end
end
