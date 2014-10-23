class IncludeOtherAsOptionInQuestions < ActiveRecord::Migration
  def self.up
  	change_table :design_details do |dt|
  		dt.boolean :include_other_as_option
  	end
  	change_table :arm_details do |ad|
  		ad.boolean :include_other_as_option
  	end
  	change_table :baseline_characteristics do |bc|
  		bc.boolean :include_other_as_option
  	end
  end

  def self.down
  end
end
