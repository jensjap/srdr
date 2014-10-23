class AddExtractionFormIdToDataPoints < ActiveRecord::Migration
  def self.up
	add_column :outcome_data_points, :extraction_form_id, :integer
  end

  def self.down
	remove_column :outcome_data_points, :extraction_form_id  
  end
end
