class UpdateDesignDetailTablesForSubquestion < ActiveRecord::Migration
  def self.up
  	change_table :design_detail_data_points do |t|
  		t.string :subquestion_value
  	end
	
  	change_table :design_detail_fields do |t|
  		t.string :subquestion
  		t.string :options_with_subquestions
  	end  	
  end

  def self.down
  end
end
