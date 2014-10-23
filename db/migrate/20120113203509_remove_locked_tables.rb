class RemoveLockedTables < ActiveRecord::Migration
  def self.up
	drop_table :locked_extraction_form_sections
	drop_table :locked_template_sections
	drop_table :outcome_analyses
	drop_table :sticky_notes
	drop_table :sticky_note_replies
	drop_table :templates
	drop_table :template_outcome_columns
	drop_table :template_outcome_names
	drop_table :study_templates
	drop_table :study_template_sections
	drop_table :publications
	drop_table :quality_aspects
	drop_table :exclusion_criteria_items
  end

  def self.down
  end
end
