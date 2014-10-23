class CreateDefaultOutcomeMeasuresTable < ActiveRecord::Migration
  def self.up
  	create_table :default_outcome_measures do |t|
  		t.string :outcome_type
  		t.string :name
  		t.string :description
  		t.string :unit
  	end
  end

  def self.down
  end
end
