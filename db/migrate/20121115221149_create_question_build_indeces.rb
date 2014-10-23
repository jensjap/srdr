class CreateQuestionBuildIndeces < ActiveRecord::Migration
  def self.up
  	# design details
  	add_index :design_details, [:extraction_form_id, :question_number], :name=>'dd_efix'
  	add_index :design_detail_fields, [:design_detail_id, :row_number], :name=>'ddf_ddix'
  	add_index :design_detail_data_points, [:design_detail_field_id, :study_id], :name=>'dddp_ddix'
  	add_index :matrix_dropdown_options, [:column_id, :model_name], :name=>'mdo_cix'

  	# baseline characteristics
  	add_index :baseline_characteristics, [:extraction_form_id, :question_number], :name=>'bc_efix'
  	add_index :baseline_characteristic_fields, [:baseline_characteristic_id, :row_number], :name=>'bcf_bcix'
  	add_index :baseline_characteristic_data_points, [:baseline_characteristic_field_id, :study_id], :name=>'bcdp_bcix'

  	# arm details
  	add_index :arm_details, [:extraction_form_id, :question_number], :name=>'ad_efix'
  	add_index :arm_detail_fields, [:arm_detail_id, :row_number], :name=>'adf_adix'
  	add_index :arm_detail_data_points, [:arm_detail_field_id, :study_id], :name=>'addp_adix'

  	# outcome details
  	add_index :outcome_details, [:extraction_form_id, :question_number], :name=>'od_efix'
  	add_index :outcome_detail_fields, [:outcome_detail_id, :row_number], :name=>'odf_odix'
  	add_index :outcome_detail_data_points, [:outcome_detail_field_id, :study_id], :name=>'oddp_odix'
  end

  def self.down
  	remove_index :design_details, :name=>'dd_efix'
  	remove_index :design_detail_fields, :name=>'ddf_ddix'
  	remove_index :design_detail_data_points, :name=>'dddp_ddix'
  	remove_index :matrix_dropdown_options, :name=>'mdo_cix'

  	remove_index :baseline_characteristics, :name=>'bc_efix'
  	remove_index :baseline_characteristic_fields, :name=>'bcf_bcix'
  	remove_index :design_detail_data_points, :name=>'bcdp_bcix'
  	
  	remove_index :arm_details, :name=>'ad_efix'
  	remove_index :arm_detail_fields, :name=>'adf_adix'
  	remove_index :arm_detail_data_points, :name=>'addp_adix'
  	
  	remove_index :outcome_details, :name=>'od_efix'
  	remove_index :outcome_detail_fields, :name=>'odf_odix'
  	remove_index :outcome_detail_data_points, :name=>'oddp_odix'
  end
end
