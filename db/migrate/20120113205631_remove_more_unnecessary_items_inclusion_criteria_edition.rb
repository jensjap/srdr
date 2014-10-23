class RemoveMoreUnnecessaryItemsInclusionCriteriaEdition < ActiveRecord::Migration
  def self.up
	drop_table :inclusion_criteria_items
	drop_table :outcome_enrolled_numbers
	drop_table :publication_numbers
	drop_table :quality_rating_template_fields
	drop_table :custom_templates
	drop_table :studies_key_questions
	drop_table :study_extraction_form_sections
	remove_column :studies, :title
	remove_column :study_extraction_forms, :notes
  end

  def self.down
  end
end
