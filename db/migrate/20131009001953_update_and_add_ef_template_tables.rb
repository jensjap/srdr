class UpdateAndAddEfTemplateTables < ActiveRecord::Migration
  def self.up
  	#--------------------------
  	# update eft_design_details
  	change_table :eft_design_details do |t1|
        t1.boolean :is_matrix
        t1.boolean :include_other_as_option
  	end
  	# update eft_design_detail_fields
  	#  Not necessary - up to date
  	#--------------------------
  	# update eft_baseline_characteristics
  	change_table :eft_baseline_characteristics do |t3|
        t3.boolean :is_matrix
        t3.boolean :include_other_as_option
  	end
  	# update eft_baseline_characteristic_fields
  	#  Not necessary - up to date
  	#--------------------------
  	# create eft_arm_details
  	create_table :eft_arm_details do |t5|
        t5.integer :extraction_form_template_id
        t5.text :question
        t5.string :field_type
        t5.string :field_note
        t5.integer :question_number
        t5.text :instruction
        t5.boolean :is_matrix
        t5.boolean :include_other_as_option
    end
  	# create eft_arm_detail_fields
    create_table :eft_arm_detail_fields do |t6|
        t6.integer :eft_arm_detail_id
        t6.string :option_text
        t6.string :subquestion
        t6.boolean :has_subquestion
        t6.integer :row_number
        t6.integer :column_number
    end
  	#--------------------------
  	# create eft_outcome_details
    create_table :eft_outcome_details do |t7|
        t7.integer :extraction_form_template_id
        t7.text :question
        t7.string :field_type
        t7.string :field_note
        t7.integer :question_number
        t7.text :instruction
        t7.boolean :is_matrix
        t7.boolean :include_other_as_option
    end
  	# create eft_outcome_detail_fields
    create_table :eft_outcome_detail_fields do |t8|
        t8.integer :eft_outcome_detail_id
        t8.string :option_text
        t8.string :subquestion
        t8.boolean :has_subquestion
        t8.integer :row_number
        t8.integer :column_number
    end
    #--------------------------
    # create eft_diagnostic_test_details
    create_table :eft_diagnostic_test_details do |t10|
        t10.integer :extraction_form_template_id
        t10.text :question
        t10.string :field_type
        t10.string :field_note
        t10.integer :question_number
        t10.text :instruction
        t10.boolean :is_matrix
        t10.boolean :include_other_as_option
    end
    # create eft_diagnostic_test_detail_fields
    create_table :eft_diagnostic_test_detail_fields do |t11|
        t11.integer :eft_diagnostic_test_detail_id
        t11.string :option_text
        t11.string :subquestion
        t11.boolean :has_subquestion
        t11.integer :row_number
        t11.integer :column_number
    end
  	#--------------------------
  	# create eft_matrix_dropdowns
    create_table :eft_matrix_dropdown_options do |t12|
        t12.integer :row_id
        t12.integer :column_id
        t12.string :option_text
        t12.integer :option_number
        t12.string :model_name
    end
  end

  def self.down
  end
end
