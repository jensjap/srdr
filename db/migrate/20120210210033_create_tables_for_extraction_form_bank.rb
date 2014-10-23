class CreateTablesForExtractionFormBank < ActiveRecord::Migration
  def self.up
    # TEMPLATE EXTRACTION FORM SECTIONS
  	create_table :eft_sections do |t|
  		t.integer :extraction_form_template_id
  		t.string :section_name
  		t.boolean :included
  	end
    
    # EXTRACTION FORM TEMPLATE ARMS
  	create_table :eft_arms do |t|
  		t.integer :extraction_form_template_id
  		t.string :name
  		t.string :description
  		t.string :note
  	end
    
    # EXTRACTION FORM OUTCOME NAMES
    create_table :eft_outcome_names do |t|
      t.string :title
      t.string :note
      t.integer :extraction_form_template_id
      t.string :outcome_type
    end

    # EXTRACTION FORM DESIGN DETAILS
    create_table :eft_design_details do |t|
      t.integer :extraction_form_template_id
      t.text :question
      t.string :field_type
      t.string :field_note
      t.integer :question_number
      t.text :instruction
    end
    
    # EXTRACTION FORM DESIGN DETAIL FIELDS
    create_table :eft_design_detail_fields do |t|
      t.integer :eft_design_detail_id
      t.string :option_text
      t.string :subquestion
      t.boolean :has_subquestion
    end

    # EXTRACTION FORM BASELINE CHARACTERISTICS
    create_table :eft_baseline_characteristics do |t|
      t.integer :extraction_form_template_id
      t.text :question
      t.string :field_type
      t.string :field_notes
      t.integer :question_number
      t.text :instruction
    end

    # EXTRACTION FORM BASELINE CHARACTERISTIC FIELDS
    create_table :eft_baseline_characteristic_fields do |t|
      t.integer :eft_baseline_characteristic_id
      t.string :option_text
      t.string :subquestion
      t.boolean :has_subquestion
    end

    # EXTRACTION FORM ADVERSE EVENT COLUMNS
    create_table :eft_adverse_event_columns do |t|
      t.string :name
      t.string :description
      t.integer :extraction_form_template_id
    end

    # EXTRACTION FORM QUALITY DIMENSION FIELDS
    create_table :eft_quality_dimension_fields do |t|
      t.string :title
      t.text :field_notes
      t.integer :extraction_form_template_id
    end

    # EXTRACTION FORM QUALITY RATING FIELDS
    create_table :eft_quality_rating_fields do |t|
      t.integer :extraction_form_template_id
      t.string :rating_item
      t.integer :display_number
    end
  end

  def self.down
  end
end
