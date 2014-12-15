class CreateCevgMeasuresTable < ActiveRecord::Migration
  #results_type is 0 for normal results page, 1 for comparison

  # measure_type was originally used to group measures together into various
  # sections such as descriptive, adjusted, etc., but I think we stopped using it.
  def self.up
    create_table :default_cevg_measures do |t|
      t.integer :results_type
      t.string :outcome_type
      t.string :title
      t.string :description
      t.string :unit
      t.integer :measure_type, :default=>1
      t.boolean :is_default, :default=>false
    end
  end

  def self.down
    drop_table :default_cevg_measures
  end
end
