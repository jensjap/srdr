class AddArmidAndOutcomeidToQuestionTables < ActiveRecord::Migration
  def self.up

  	# add arm_id and outcome_id to design_detail_data_points
  	change_table :design_detail_data_points do |t|
  		t.integer :arm_id, :default=>0
  		t.integer :outcome_id, :default=>0
  	end

  	# add arm_id and outcome_id to outcome_detail_data_points
  	change_table :outcome_detail_data_points do |t|
  		t.integer :arm_id, :default=>0
  		t.integer :outcome_id, :default=>0
  	end

  	# add outcome_id to baseline_characteristic_data_points, set default on arm_id to 0
  	change_table :baseline_characteristic_data_points do |t|
  		t.integer :outcome_id, :default=>0
  		t.change :arm_id, :integer, :default=>0
  	end

  	# add outcome_id to arm_detail_data_points, set default on arm_id to 0
  	change_table :arm_detail_data_points do |t|
  		t.integer :outcome_id, :default=>0
  		t.change :arm_id, :integer, :default=>0
  	end

  end

  def self.down
  	remove_column :design_detail_data_points, :arm_id
  	remove_column :design_detail_data_points, :outcome_id

  	remove_column :outcome_detail_data_points, :arm_id
  	remove_column :outcome_detail_data_points, :outcome_id

  	remove_column :arm_detail_data_points, :outcome_id

  	remove_column :baseline_characteristic_data_points, :outcome_id
  	
  end
end
