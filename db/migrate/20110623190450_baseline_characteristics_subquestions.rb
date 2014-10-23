class BaselineCharacteristicsSubquestions < ActiveRecord::Migration
  def self.up
  	change_table :baseline_characteristics do |t|
  		t.string :instruction
  	end
  	change_table :baseline_characteristic_data_points do |t|
  		t.string :subquestion_val
  	end
  	change_table :baseline_characteristic_fields do |t|
  		t.string :subquestion
  		t.boolean :has_subquestion
  	end
  end

  def self.down
  end
end
