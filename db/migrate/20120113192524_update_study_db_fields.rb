class UpdateStudyDbFields < ActiveRecord::Migration
  def self.up
	#remove_column :studies, :extraction_form_id
	#remove_column :studies, :study_type
	#remove_column :studies, :study_title
	#drop_table :adverse_event_arms
	#drop_table :adverse_event_template_settings
	#remove_column :baseline_characteristics, :study_id	
	#remove_column :design_details, :study_id	
  end

  def self.down
  end
end
