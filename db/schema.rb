# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20151117190535) do

  create_table "add_type_to_roles", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_event_arms", :force => true do |t|
    t.integer  "study_id"
    t.integer  "adverse_event_id"
    t.integer  "arm_id"
    t.integer  "num_affected"
    t.integer  "num_at_risk"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_event_columns", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_event_results", :force => true do |t|
    t.integer  "column_id"
    t.text     "value"
    t.integer  "adverse_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "arm_id"
  end

  add_index "adverse_event_results", ["adverse_event_id"], :name => "StudyData"

  create_table "adverse_event_template_settings", :force => true do |t|
    t.integer  "extraction_form_id"
    t.boolean  "display_arms"
    t.boolean  "display_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverse_events", :force => true do |t|
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.text     "description"
  end

  add_index "adverse_events", ["extraction_form_id", "study_id"], :name => "StudyData"

  create_table "arm_detail_data_points", :force => true do |t|
    t.integer  "arm_detail_field_id"
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "arm_id",              :default => 0
    t.text     "subquestion_value"
    t.integer  "row_field_id",        :default => 0
    t.integer  "column_field_id",     :default => 0
    t.integer  "outcome_id",          :default => 0
  end

  add_index "arm_detail_data_points", ["arm_detail_field_id", "study_id"], :name => "addp_adix"
  add_index "arm_detail_data_points", ["arm_detail_field_id"], :name => "armdetaildatapoint_armdetailfield_idx"
  add_index "arm_detail_data_points", ["arm_id"], :name => "armdetaildatapoint_arm_idx"
  add_index "arm_detail_data_points", ["extraction_form_id", "study_id", "arm_detail_field_id", "row_field_id", "column_field_id"], :name => "StudyDataRowCol"
  add_index "arm_detail_data_points", ["extraction_form_id", "study_id", "arm_detail_field_id"], :name => "StudyData"
  add_index "arm_detail_data_points", ["extraction_form_id", "study_id", "arm_id", "arm_detail_field_id", "row_field_id", "column_field_id"], :name => "StudyDataCache2"
  add_index "arm_detail_data_points", ["extraction_form_id", "study_id", "arm_id", "arm_detail_field_id"], :name => "StudyDataCache"
  add_index "arm_detail_data_points", ["extraction_form_id", "study_id", "outcome_id", "arm_detail_field_id"], :name => "ReportBuilder0"
  add_index "arm_detail_data_points", ["extraction_form_id"], :name => "armdetaildatapoint_extractionform_idx"
  add_index "arm_detail_data_points", ["study_id"], :name => "armdetaildatapoint_study_idx"

  create_table "arm_detail_fields", :force => true do |t|
    t.integer  "arm_detail_id"
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",   :default => 0
    t.integer  "row_number",      :default => 0
  end

  add_index "arm_detail_fields", ["arm_detail_id", "column_number", "row_number"], :name => "StudyDataColRow"
  add_index "arm_detail_fields", ["arm_detail_id", "column_number"], :name => "StudyDataCol"
  add_index "arm_detail_fields", ["arm_detail_id", "row_number"], :name => "adf_adix"
  add_index "arm_detail_fields", ["arm_detail_id"], :name => "armdetailfield_armdetail_idx"

  create_table "arm_details", :force => true do |t|
    t.text     "question"
    t.integer  "extraction_form_id"
    t.string   "field_type"
    t.string   "field_note"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  add_index "arm_details", ["extraction_form_id", "question_number"], :name => "StudyDataSorted"
  add_index "arm_details", ["extraction_form_id", "question_number"], :name => "ad_efix"
  add_index "arm_details", ["extraction_form_id"], :name => "StudyData"
  add_index "arm_details", ["extraction_form_id"], :name => "armdetail_extractionform_idx"

  create_table "arms", :force => true do |t|
    t.integer  "study_id"
    t.string   "title"
    t.text     "description"
    t.integer  "display_number"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_suggested_by_admin", :default => false
    t.string   "note"
    t.integer  "efarm_id"
    t.integer  "default_num_enrolled"
    t.boolean  "is_intention_to_treat", :default => true
  end

  add_index "arms", ["extraction_form_id", "study_id"], :name => "StudyData"
  add_index "arms", ["extraction_form_id"], :name => "arm_extractionform_idx"
  add_index "arms", ["study_id"], :name => "arm_study_idx"

  create_table "baseline_characteristic_data_points", :force => true do |t|
    t.integer  "baseline_characteristic_field_id"
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "arm_id",                           :default => 0
    t.text     "subquestion_value"
    t.integer  "row_field_id",                     :default => 0
    t.integer  "column_field_id",                  :default => 0
    t.integer  "outcome_id",                       :default => 0
    t.integer  "diagnostic_test_id",               :default => 0
  end

  add_index "baseline_characteristic_data_points", ["arm_id"], :name => "baselinecharacteristicdatapoint_arm_idx"
  add_index "baseline_characteristic_data_points", ["baseline_characteristic_field_id", "study_id"], :name => "bcdp_bcix"
  add_index "baseline_characteristic_data_points", ["baseline_characteristic_field_id"], :name => "baselinecharacteristicdatapoint_baselinefield_idx"
  add_index "baseline_characteristic_data_points", ["extraction_form_id", "baseline_characteristic_field_id", "study_id"], :name => "StudyData"
  add_index "baseline_characteristic_data_points", ["extraction_form_id", "study_id", "arm_id", "baseline_characteristic_field_id", "row_field_id", "column_field_id"], :name => "StudyDataCache2"
  add_index "baseline_characteristic_data_points", ["extraction_form_id", "study_id", "arm_id", "baseline_characteristic_field_id"], :name => "StudyDataCache"
  add_index "baseline_characteristic_data_points", ["extraction_form_id", "study_id", "outcome_id", "baseline_characteristic_field_id"], :name => "ReportBuilder1"
  add_index "baseline_characteristic_data_points", ["extraction_form_id"], :name => "baselinecharacteristicdatapoint_extractionform_idx"
  add_index "baseline_characteristic_data_points", ["study_id"], :name => "baselinecharacteristicdatapoint_study_idx"

  create_table "baseline_characteristic_fields", :force => true do |t|
    t.integer  "baseline_characteristic_id"
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",              :default => 0
    t.integer  "row_number",                 :default => 0
  end

  add_index "baseline_characteristic_fields", ["baseline_characteristic_id", "column_number", "row_number"], :name => "StudyDataCache"
  add_index "baseline_characteristic_fields", ["baseline_characteristic_id", "row_number"], :name => "bcf_bcix"
  add_index "baseline_characteristic_fields", ["baseline_characteristic_id"], :name => "baselinecharacteristicfield_baselinecharacteristic_idx"

  create_table "baseline_characteristic_subcategory_data_points", :force => true do |t|
    t.integer  "baseline_characteristic_subcategory_field_id"
    t.integer  "arm_id"
    t.boolean  "is_total"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baseline_characteristic_subcategory_fields", :force => true do |t|
    t.string   "subcategory_title"
    t.integer  "baseline_characteristic_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baseline_characteristics", :force => true do |t|
    t.text     "question"
    t.string   "field_type"
    t.integer  "extraction_form_id"
    t.string   "field_notes"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  add_index "baseline_characteristics", ["extraction_form_id", "question_number"], :name => "bc_efix"
  add_index "baseline_characteristics", ["extraction_form_id"], :name => "StudyData"
  add_index "baseline_characteristics", ["extraction_form_id"], :name => "baselinecharacteristic_extractionform_idx"

  create_table "comments", :force => true do |t|
    t.text     "comment_text"
    t.integer  "commenter_id"
    t.string   "fact_or_opinion"
    t.string   "post_type"
    t.boolean  "is_public"
    t.boolean  "is_reply"
    t.integer  "reply_to"
    t.text     "value_at_comment_time"
    t.boolean  "is_flag"
    t.string   "flag_type"
    t.boolean  "is_high_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_name"
    t.integer  "section_id"
    t.string   "field_name"
    t.integer  "study_id"
    t.integer  "project_id"
  end

  add_index "comments", ["section_id", "section_name", "study_id"], :name => "comment_sectionix"

  create_table "comparators", :force => true do |t|
    t.integer  "comparison_id"
    t.string   "comparator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comparators", ["comparison_id"], :name => "EDIT_TAB"
  add_index "comparators", ["comparison_id"], :name => "comparator_comparison_idx"

  create_table "comparison_data_points", :force => true do |t|
    t.text     "value"
    t.string   "footnote"
    t.boolean  "is_calculated"
    t.integer  "comparison_measure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comparator_id"
    t.integer  "arm_id",                :default => 0
    t.integer  "footnote_number",       :default => 0
    t.integer  "table_cell"
  end

  add_index "comparison_data_points", ["arm_id"], :name => "comparisondatapoint_arm_idx"
  add_index "comparison_data_points", ["comparator_id", "comparison_measure_id", "arm_id"], :name => "StudyDataCache2"
  add_index "comparison_data_points", ["comparator_id", "comparison_measure_id"], :name => "StudyDataCache"
  add_index "comparison_data_points", ["comparator_id"], :name => "comparisondatapoint_comparator_idx"
  add_index "comparison_data_points", ["comparison_measure_id", "comparator_id"], :name => "EDIT_TAB"
  add_index "comparison_data_points", ["comparison_measure_id"], :name => "comparisondatapoint_comparisonmeasure_idx"

  create_table "comparison_measures", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "unit"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comparison_id"
    t.integer  "measure_type",  :default => 0
  end

  add_index "comparison_measures", ["comparison_id"], :name => "EDIT_TAB"
  add_index "comparison_measures", ["comparison_id"], :name => "comparisonmeasure_comparison_idx"

  create_table "comparisons", :force => true do |t|
    t.string   "within_or_between"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.integer  "outcome_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subgroup_id",        :default => 0
    t.integer  "section",            :default => 0
  end

  add_index "comparisons", ["extraction_form_id", "study_id", "outcome_id", "subgroup_id", "within_or_between"], :name => "StudyDataCache"
  add_index "comparisons", ["extraction_form_id"], :name => "comparison_extractionform_idx"
  add_index "comparisons", ["group_id"], :name => "comparison_group_idx"
  add_index "comparisons", ["outcome_id"], :name => "comparison_outcome_idx"
  add_index "comparisons", ["study_id"], :name => "comparison_study_idx"
  add_index "comparisons", ["within_or_between", "group_id", "outcome_id", "study_id", "extraction_form_id", "subgroup_id"], :name => "EDIT_TAB"

  create_table "complete_study_sections", :force => true do |t|
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.integer  "flagged_by_user"
    t.boolean  "is_complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_name"
  end

  create_table "counts", :id => false, :force => true do |t|
    t.integer "EFID",                   :default => 0
    t.boolean "ArmD"
    t.integer "nArmD",     :limit => 8, :default => 0
    t.boolean "OutcomeD"
    t.integer "nOutcomeD", :limit => 8, :default => 0
    t.boolean "BaseD"
    t.integer "nBaseD",    :limit => 8, :default => 0
    t.boolean "DesignD"
    t.integer "nDesignD",  :limit => 8, :default => 0
    t.boolean "DxTestD"
    t.integer "nDxTestD",  :limit => 8, :default => 0
    t.integer "QualityD",  :limit => 8, :default => 0
  end

  create_table "daa_markers", :force => true do |t|
    t.string   "section"
    t.integer  "datapoint_id"
    t.integer  "marker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "status",           :default => "pending"
    t.text     "message"
    t.datetime "requested_at"
    t.integer  "responder_id"
    t.datetime "responded_at"
    t.datetime "last_download_at"
    t.integer  "download_count",   :default => 0
    t.integer  "request_count",    :default => 0
  end

  create_table "default_adverse_event_columns", :force => true do |t|
    t.string   "header"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_cevg_measures", :force => true do |t|
    t.integer "results_type"
    t.string  "outcome_type"
    t.string  "title"
    t.string  "description"
    t.string  "unit"
    t.integer "measure_type", :default => 1
    t.boolean "is_default",   :default => false
  end

  create_table "default_comparison_measures", :force => true do |t|
    t.string  "outcome_type"
    t.string  "title"
    t.string  "description"
    t.string  "unit"
    t.boolean "is_default",        :default => false
    t.integer "measure_type",      :default => 0
    t.integer "within_or_between", :default => 0
  end

  create_table "default_design_details", :force => true do |t|
    t.string   "title"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_columns", :force => true do |t|
    t.string   "column_name"
    t.string   "column_description"
    t.string   "column_header"
    t.string   "outcome_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_comparison_columns", :force => true do |t|
    t.string   "column_name"
    t.string   "column_description"
    t.string   "column_header"
    t.string   "outcome_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_outcome_measures", :force => true do |t|
    t.string  "outcome_type"
    t.string  "title"
    t.string  "description"
    t.string  "unit"
    t.boolean "is_default",   :default => false
    t.integer "measure_type", :default => 0
  end

  create_table "default_quality_rating_fields", :force => true do |t|
    t.string   "rating_item"
    t.integer  "display_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                         :default => 0, :null => false
    t.integer  "attempts",                         :default => 0, :null => false
    t.text     "handler",    :limit => 2147483647,                :null => false
    t.text     "last_error", :limit => 2147483647
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "design_detail_data_points", :force => true do |t|
    t.integer  "design_detail_field_id"
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subquestion_value"
    t.integer  "row_field_id",           :default => 0
    t.integer  "column_field_id",        :default => 0
    t.integer  "arm_id",                 :default => 0
    t.integer  "outcome_id",             :default => 0
  end

  add_index "design_detail_data_points", ["design_detail_field_id", "study_id"], :name => "dddp_ddix"
  add_index "design_detail_data_points", ["design_detail_field_id"], :name => "designdetaildatapoint_designfield_idx"
  add_index "design_detail_data_points", ["extraction_form_id", "study_id", "design_detail_field_id", "row_field_id", "column_field_id"], :name => "StudyDataCache"
  add_index "design_detail_data_points", ["extraction_form_id", "study_id", "design_detail_field_id"], :name => "StudyData"
  add_index "design_detail_data_points", ["extraction_form_id"], :name => "designdetaildatapoint_extractionform_idx"
  add_index "design_detail_data_points", ["study_id"], :name => "designdetaildatapoint_study_idx"

  create_table "design_detail_fields", :force => true do |t|
    t.integer  "design_detail_id"
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",    :default => 0
    t.integer  "row_number",       :default => 0
  end

  add_index "design_detail_fields", ["design_detail_id", "column_number", "row_number"], :name => "StudyDataColRow"
  add_index "design_detail_fields", ["design_detail_id", "column_number"], :name => "StudyDataCol"
  add_index "design_detail_fields", ["design_detail_id", "row_number"], :name => "ddf_ddix"
  add_index "design_detail_fields", ["design_detail_id"], :name => "designdetailfield_designdetail_idx"

  create_table "design_detail_subcategory_data_points", :force => true do |t|
    t.integer  "design_detail_subcategory_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "study_id"
    t.string   "value"
    t.string   "notes"
  end

  create_table "design_detail_subcategory_fields", :force => true do |t|
    t.string   "subcategory_title"
    t.integer  "design_detail_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "design_details", :force => true do |t|
    t.text     "question"
    t.integer  "extraction_form_id"
    t.string   "field_type"
    t.string   "field_note"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  add_index "design_details", ["extraction_form_id", "question_number"], :name => "dd_efix"
  add_index "design_details", ["extraction_form_id"], :name => "StudyData"
  add_index "design_details", ["extraction_form_id"], :name => "designdetail_extractionform_idx"

  create_table "diagnostic_test_detail_data_points", :force => true do |t|
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subquestion_value"
    t.integer  "row_field_id",                    :default => 0
    t.integer  "column_field_id",                 :default => 0
    t.integer  "diagnostic_test_detail_field_id"
    t.integer  "diagnostic_test_id"
  end

  create_table "diagnostic_test_detail_fields", :force => true do |t|
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",             :default => 0
    t.integer  "row_number",                :default => 0
    t.integer  "diagnostic_test_detail_id"
  end

  create_table "diagnostic_test_details", :force => true do |t|
    t.text     "question"
    t.integer  "extraction_form_id"
    t.string   "field_type"
    t.string   "field_note"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  create_table "diagnostic_test_thresholds", :force => true do |t|
    t.integer  "diagnostic_test_id"
    t.string   "threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diagnostic_tests", :force => true do |t|
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.integer  "test_type"
    t.string   "title"
    t.text     "description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ef_instructions", :force => true do |t|
    t.integer  "ef_id"
    t.string   "section"
    t.string   "data_element"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ef_section_options", :force => true do |t|
    t.integer "extraction_form_id",                    :null => false
    t.string  "section"
    t.boolean "by_arm",             :default => false
    t.boolean "by_outcome",         :default => false
    t.boolean "include_total",      :default => false
    t.boolean "by_diagnostic_test", :default => false
  end

  create_table "eft_adverse_event_columns", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "extraction_form_template_id"
  end

  create_table "eft_arm_detail_fields", :force => true do |t|
    t.integer "eft_arm_detail_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_arm_details", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.text    "question",                    :limit => 16777215
    t.string  "field_type"
    t.string  "field_note"
    t.integer "question_number"
    t.text    "instruction",                 :limit => 16777215
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_arms", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.string  "name"
    t.string  "description"
    t.string  "note"
  end

  create_table "eft_baseline_characteristic_fields", :force => true do |t|
    t.integer "eft_baseline_characteristic_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number",                     :default => 0
    t.integer "column_number",                  :default => 0
  end

  create_table "eft_baseline_characteristics", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.text    "question"
    t.string  "field_type"
    t.string  "field_notes"
    t.integer "question_number"
    t.text    "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_design_detail_fields", :force => true do |t|
    t.integer "eft_design_detail_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number",           :default => 0
    t.integer "column_number",        :default => 0
  end

  create_table "eft_design_details", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.text    "question"
    t.string  "field_type"
    t.string  "field_note"
    t.integer "question_number"
    t.text    "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_diagnostic_test_detail_fields", :force => true do |t|
    t.integer "eft_diagnostic_test_detail_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_diagnostic_test_details", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.text    "question"
    t.string  "field_type"
    t.string  "field_note"
    t.integer "question_number"
    t.text    "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_diagnostic_tests", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.integer "test_type"
    t.string  "title"
    t.text    "description"
    t.text    "notes"
  end

  create_table "eft_matrix_dropdown_options", :force => true do |t|
    t.integer "row_id"
    t.integer "column_id"
    t.string  "option_text"
    t.integer "option_number"
    t.string  "model_name"
  end

  create_table "eft_outcome_detail_fields", :force => true do |t|
    t.integer "eft_outcome_detail_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_outcome_details", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.text    "question",                    :limit => 16777215
    t.string  "field_type"
    t.string  "field_note"
    t.integer "question_number"
    t.text    "instruction",                 :limit => 16777215
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_outcome_names", :force => true do |t|
    t.string  "title"
    t.string  "note"
    t.integer "extraction_form_template_id"
    t.string  "outcome_type"
  end

  create_table "eft_quality_detail_fields", :force => true do |t|
    t.integer "eft_quality_detail_id"
    t.string  "option_text"
    t.string  "subquestion"
    t.boolean "has_subquestion"
    t.integer "row_number"
    t.integer "column_number"
  end

  create_table "eft_quality_details", :force => true do |t|
    t.integer "extraction_form_id"
    t.text    "question"
    t.string  "field_type"
    t.string  "field_note"
    t.integer "question_number"
    t.text    "instruction"
    t.boolean "is_matrix"
    t.boolean "include_other_as_option"
  end

  create_table "eft_quality_dimension_fields", :force => true do |t|
    t.string  "title"
    t.text    "field_notes"
    t.integer "extraction_form_template_id"
  end

  create_table "eft_quality_rating_fields", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.string  "rating_item"
    t.integer "display_number"
  end

  create_table "eft_sections", :force => true do |t|
    t.integer "extraction_form_template_id"
    t.string  "section_name"
    t.boolean "included"
  end

  create_table "extraction_form_adverse_events", :force => true do |t|
    t.string  "title"
    t.text    "description"
    t.string  "note"
    t.integer "extraction_form_id"
  end

  create_table "extraction_form_arms", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "note"
    t.integer "extraction_form_id"
  end

  add_index "extraction_form_arms", ["extraction_form_id"], :name => "extractionformarm_extractionform_idx"

  create_table "extraction_form_diagnostic_tests", :force => true do |t|
    t.integer "test_type"
    t.string  "title"
    t.text    "description"
    t.text    "notes"
    t.integer "extraction_form_id"
  end

  add_index "extraction_form_diagnostic_tests", ["extraction_form_id"], :name => "extractionformdiagnostic_extractionform_idx"

  create_table "extraction_form_key_questions", :force => true do |t|
    t.integer  "extraction_form_id"
    t.integer  "key_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "extraction_form_key_questions", ["extraction_form_id"], :name => "EDIT_TAB"
  add_index "extraction_form_key_questions", ["extraction_form_id"], :name => "extractionformkeyquestion_extractionform_idx"

  create_table "extraction_form_outcome_names", :force => true do |t|
    t.string   "title"
    t.string   "note"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outcome_type"
  end

  add_index "extraction_form_outcome_names", ["extraction_form_id"], :name => "extractionformoutcome_extractionform_idx"

  create_table "extraction_form_section_copies", :force => true do |t|
    t.string   "section_name"
    t.integer  "copied_from"
    t.integer  "copied_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "extraction_form_section_copies", ["section_name", "copied_from"], :name => "EDIT_TAB"

  create_table "extraction_form_sections", :force => true do |t|
    t.integer  "extraction_form_id"
    t.string   "section_name"
    t.boolean  "included"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "borrowed_from_efid"
  end

  add_index "extraction_form_sections", ["extraction_form_id", "section_name"], :name => "EDIT_TAB"
  add_index "extraction_form_sections", ["extraction_form_id"], :name => "extractionformsection_extractionform_idx"

  create_table "extraction_form_templates", :force => true do |t|
    t.string   "title"
    t.integer  "creator_id"
    t.text     "notes"
    t.boolean  "adverse_event_display_arms"
    t.boolean  "adverse_event_display_total"
    t.boolean  "show_to_local"
    t.boolean  "show_to_world"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "template_form_id"
  end

  create_table "extraction_forms", :force => true do |t|
    t.string   "title"
    t.integer  "creator_id"
    t.text     "notes"
    t.boolean  "adverse_event_display_arms",  :default => true
    t.boolean  "adverse_event_display_total", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.boolean  "is_ready"
    t.integer  "bank_id"
    t.boolean  "is_diagnostic",               :default => false
  end

  add_index "extraction_forms", ["creator_id"], :name => "extractionform_creator_idx"
  add_index "extraction_forms", ["project_id", "id"], :name => "StudyData"
  add_index "extraction_forms", ["project_id"], :name => "extractionform_project_idx"

  create_table "feedback_items", :force => true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.string   "page"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "footnote_fields", :force => true do |t|
    t.integer  "study_id"
    t.integer  "footnote_number"
    t.string   "field_name"
    t.string   "page_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "footnotes", :force => true do |t|
    t.integer  "note_number"
    t.integer  "study_id"
    t.string   "page_name"
    t.string   "data_type"
    t.string   "note_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "key_questions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "question_number"
    t.text     "question"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "key_questions", ["project_id"], :name => "keyquestion_project_idx"

  create_table "matrix_dropdown_options", :force => true do |t|
    t.integer "row_id"
    t.integer "column_id"
    t.string  "option_text"
    t.integer "option_number"
    t.string  "model_name"
  end

  add_index "matrix_dropdown_options", ["column_id", "model_name"], :name => "mdo_cix"
  add_index "matrix_dropdown_options", ["column_id"], :name => "matrixdropdown_column_idx"
  add_index "matrix_dropdown_options", ["row_id"], :name => "matrixdropdown_row_idx"

  create_table "notifiers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "contact"
  end

  add_index "organizations", ["name"], :name => "StudyData"

  create_table "outcome_column_values", :force => true do |t|
    t.integer  "outcome_id"
    t.integer  "timepoint_id"
    t.integer  "subgroup_id"
    t.string   "value"
    t.boolean  "is_calculated"
    t.integer  "arm_id"
    t.integer  "column_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_columns", :force => true do |t|
    t.string   "column_header"
    t.string   "outcome_type"
    t.string   "column_name"
    t.string   "column_description"
    t.integer  "extraction_form_id"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparison_columns", :force => true do |t|
    t.string   "column_header"
    t.string   "outcome_type"
    t.string   "column_name"
    t.string   "column_description"
    t.integer  "extraction_form_id"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparison_results", :force => true do |t|
    t.integer  "arm_id"
    t.integer  "outcome_id"
    t.integer  "timepoint_id"
    t.integer  "outcome_comparison_column_id"
    t.boolean  "is_calculated"
    t.string   "value"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_comparisons", :force => true do |t|
    t.integer  "arm_id"
    t.integer  "outcome_id"
    t.integer  "timepoint_id"
    t.integer  "outcome_comparison_column_id"
    t.boolean  "is_calculated"
    t.string   "value"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_data_entries", :force => true do |t|
    t.integer  "outcome_id"
    t.integer  "extraction_form_id"
    t.integer  "timepoint_id"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_number",     :default => 1
    t.integer  "subgroup_id",        :default => 0
  end

  add_index "outcome_data_entries", ["extraction_form_id", "outcome_id", "study_id"], :name => "StudyData"
  add_index "outcome_data_entries", ["extraction_form_id", "study_id", "outcome_id", "subgroup_id", "timepoint_id"], :name => "ReportBuilder0"
  add_index "outcome_data_entries", ["extraction_form_id", "study_id", "outcome_id", "subgroup_id"], :name => "StudyDataCache"
  add_index "outcome_data_entries", ["extraction_form_id"], :name => "outcomedataentry_extractionform_idx"
  add_index "outcome_data_entries", ["outcome_id", "subgroup_id"], :name => "EDIT_TAB"
  add_index "outcome_data_entries", ["outcome_id"], :name => "outcomedataentry_outcome_idx"
  add_index "outcome_data_entries", ["study_id"], :name => "outcomedataentry_study_idx"
  add_index "outcome_data_entries", ["subgroup_id"], :name => "outcomedataentry_subgroup_idx"
  add_index "outcome_data_entries", ["timepoint_id"], :name => "outcomedataentry_timepoint_idx"

  create_table "outcome_data_points", :force => true do |t|
    t.integer  "outcome_measure_id"
    t.text     "value"
    t.string   "footnote"
    t.boolean  "is_calculated",      :default => false
    t.integer  "arm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "footnote_number",    :default => 0
  end

  add_index "outcome_data_points", ["arm_id", "outcome_measure_id"], :name => "ReportBuilder0"
  add_index "outcome_data_points", ["arm_id"], :name => "outcomedatapoint_arm_idx"
  add_index "outcome_data_points", ["outcome_measure_id"], :name => "StudyData"
  add_index "outcome_data_points", ["outcome_measure_id"], :name => "outcomedatapoint_outcomemeasurue_idx"

  create_table "outcome_detail_data_points", :force => true do |t|
    t.integer  "outcome_detail_field_id"
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subquestion_value"
    t.integer  "row_field_id",            :default => 0
    t.integer  "column_field_id",         :default => 0
    t.integer  "arm_id",                  :default => 0
    t.integer  "outcome_id",              :default => 0
  end

  add_index "outcome_detail_data_points", ["extraction_form_id", "study_id", "outcome_detail_field_id", "row_field_id", "column_field_id"], :name => "StudyDataRowCol"
  add_index "outcome_detail_data_points", ["extraction_form_id", "study_id", "outcome_detail_field_id"], :name => "StudyData"
  add_index "outcome_detail_data_points", ["extraction_form_id"], :name => "outcomedetaildatapoint_extractionform_idx"
  add_index "outcome_detail_data_points", ["outcome_detail_field_id", "study_id"], :name => "oddp_odix"
  add_index "outcome_detail_data_points", ["outcome_detail_field_id"], :name => "outcomedetaildatapoint_outcomedetailfield_idx"
  add_index "outcome_detail_data_points", ["study_id"], :name => "outcomedetaildatapoint_study_idx"

  create_table "outcome_detail_fields", :force => true do |t|
    t.integer  "outcome_detail_id"
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",     :default => 0
    t.integer  "row_number",        :default => 0
  end

  add_index "outcome_detail_fields", ["outcome_detail_id", "column_number", "row_number"], :name => "StudyDataColRow"
  add_index "outcome_detail_fields", ["outcome_detail_id", "column_number"], :name => "StudyDataCol"
  add_index "outcome_detail_fields", ["outcome_detail_id", "row_number"], :name => "odf_odix"
  add_index "outcome_detail_fields", ["outcome_detail_id"], :name => "outcomedetailfield_outcomedetail_idx"

  create_table "outcome_details", :force => true do |t|
    t.text     "question"
    t.integer  "extraction_form_id"
    t.string   "field_type"
    t.string   "field_note"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  add_index "outcome_details", ["extraction_form_id", "question_number"], :name => "od_efix"
  add_index "outcome_details", ["extraction_form_id"], :name => "StudyData"
  add_index "outcome_details", ["extraction_form_id"], :name => "outcomedetail_extractionform_idx"

  create_table "outcome_measures", :force => true do |t|
    t.integer  "outcome_data_entry_id"
    t.string   "title"
    t.text     "description"
    t.string   "unit"
    t.string   "note"
    t.integer  "measure_type",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outcome_measures", ["outcome_data_entry_id"], :name => "StudyData"
  add_index "outcome_measures", ["outcome_data_entry_id"], :name => "outcomemeasure_outcomedataentry_idx"

  create_table "outcome_results", :force => true do |t|
    t.integer  "arm_id"
    t.integer  "outcome_id"
    t.integer  "timepoint_id"
    t.integer  "outcome_column_id"
    t.boolean  "is_calculated"
    t.string   "value"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outcome_results", ["outcome_id", "extraction_form_id", "arm_id", "timepoint_id"], :name => "StudyDataArmTP"
  add_index "outcome_results", ["outcome_id", "extraction_form_id"], :name => "StudyData"

  create_table "outcome_results_notes", :force => true do |t|
    t.integer  "outcome_id"
    t.integer  "timepoint_id"
    t.integer  "subgroup_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcome_subgroups", :force => true do |t|
    t.integer  "outcome_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outcome_subgroups", ["outcome_id"], :name => " outcomesubgroup_outcome_idx"
  add_index "outcome_subgroups", ["outcome_id"], :name => "EDIT_TAB"

  create_table "outcome_timepoint_results", :force => true do |t|
    t.integer  "outcome_id"
    t.integer  "study_id"
    t.integer  "arm_id"
    t.integer  "timepoint_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_calculated"
  end

  create_table "outcome_timepoints", :force => true do |t|
    t.integer  "outcome_id"
    t.string   "number"
    t.string   "time_unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outcome_timepoints", ["outcome_id"], :name => "EDIT_TAB"
  add_index "outcome_timepoints", ["outcome_id"], :name => "outcometimepoint_outcome_idx"

  create_table "outcomes", :force => true do |t|
    t.integer  "study_id"
    t.string   "title"
    t.boolean  "is_primary"
    t.string   "units"
    t.text     "description"
    t.text     "notes"
    t.string   "outcome_type"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outcomes", ["extraction_form_id", "study_id"], :name => "StudyData"
  add_index "outcomes", ["extraction_form_id"], :name => "outcome_extractionform_idx"
  add_index "outcomes", ["study_id", "outcome_type", "extraction_form_id"], :name => "EDIT_TAB"
  add_index "outcomes", ["study_id"], :name => "outcome_study_idx"

  create_table "primary_publication_numbers", :force => true do |t|
    t.integer  "primary_publication_id"
    t.string   "number"
    t.string   "number_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "primary_publication_numbers", ["primary_publication_id"], :name => "primarypublicationnumber_primarypublication_idx"

  create_table "primary_publications", :force => true do |t|
    t.integer  "study_id"
    t.text     "title"
    t.text     "author"
    t.text     "country"
    t.string   "year"
    t.string   "pmid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "journal"
    t.string   "volume"
    t.string   "issue"
    t.string   "trial_title"
    t.text     "abstract"
  end

  add_index "primary_publications", ["study_id"], :name => "StudyData"
  add_index "primary_publications", ["study_id"], :name => "primarypublication_study_idx"

  create_table "project_copy_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "clone_id"
    t.boolean  "include_forms"
    t.boolean  "include_studies"
    t.boolean  "include_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_copy_requests", ["user_id"], :name => "index_project_copy_requests_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "notes"
    t.string   "funding_source"
    t.integer  "creator_id"
    t.boolean  "is_public",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contributors"
    t.text     "methodology"
    t.string   "prospero_id"
    t.string   "search_strategy_filepath"
    t.boolean  "public_downloadable",      :default => false
    t.datetime "publication_requested_at"
    t.integer  "parent_id"
    t.text     "attribution"
    t.string   "doi_id"
    t.string   "management_file_url"
  end

  add_index "projects", ["creator_id"], :name => "project_creator_idx"

  create_table "quality_detail_data_points", :force => true do |t|
    t.integer  "quality_detail_field_id"
    t.text     "value"
    t.text     "notes"
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "subquestion_value"
    t.integer  "row_field_id",            :default => 0
    t.integer  "column_field_id",         :default => 0
    t.integer  "arm_id",                  :default => 0
    t.integer  "outcome_id",              :default => 0
  end

  add_index "quality_detail_data_points", ["quality_detail_field_id", "study_id"], :name => "qddp_odix"

  create_table "quality_detail_fields", :force => true do |t|
    t.integer  "quality_detail_id"
    t.string   "option_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subquestion"
    t.boolean  "has_subquestion"
    t.integer  "column_number",     :default => 0
    t.integer  "row_number",        :default => 0
  end

  add_index "quality_detail_fields", ["quality_detail_id", "row_number"], :name => "qdf_odix"

  create_table "quality_details", :force => true do |t|
    t.text     "question"
    t.integer  "extraction_form_id"
    t.string   "field_type"
    t.string   "field_note"
    t.integer  "question_number"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.boolean  "is_matrix",               :default => false
    t.boolean  "include_other_as_option"
  end

  add_index "quality_details", ["extraction_form_id", "question_number"], :name => "qd_efix"

  create_table "quality_dimension_data_points", :force => true do |t|
    t.integer  "quality_dimension_field_id"
    t.string   "value"
    t.text     "notes"
    t.integer  "study_id"
    t.string   "field_type"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quality_dimension_data_points", ["extraction_form_id", "quality_dimension_field_id", "study_id"], :name => "StudyData"
  add_index "quality_dimension_data_points", ["extraction_form_id", "study_id", "quality_dimension_field_id"], :name => "StudyDataCache"
  add_index "quality_dimension_data_points", ["quality_dimension_field_id"], :name => "qualitydimensiondatapoint_qualitydimensionfield_idx"

  create_table "quality_dimension_fields", :force => true do |t|
    t.text     "title"
    t.text     "field_notes"
    t.integer  "extraction_form_id"
    t.integer  "study_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_number"
  end

  add_index "quality_dimension_fields", ["extraction_form_id"], :name => "StudyData"
  add_index "quality_dimension_fields", ["extraction_form_id"], :name => "qualitydimensionfield_extractionform_idx"

  create_table "quality_rating_data_points", :force => true do |t|
    t.integer  "study_id"
    t.string   "guideline_used"
    t.string   "current_overall_rating"
    t.text     "notes"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quality_rating_data_points", ["extraction_form_id", "study_id"], :name => "StudyData"
  add_index "quality_rating_data_points", ["extraction_form_id"], :name => "qualityratingdatapoint_extractionform_idx"
  add_index "quality_rating_data_points", ["study_id"], :name => "qualityratingdatapoint_study_idx"

  create_table "quality_rating_fields", :force => true do |t|
    t.integer  "extraction_form_id"
    t.string   "rating_item"
    t.integer  "display_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quality_rating_fields", ["extraction_form_id"], :name => "qualityratingfield_extractionform_idx"

  create_table "quality_ratings", :force => true do |t|
    t.integer  "study_id"
    t.string   "guideline_used"
    t.string   "current_overall_rating"
    t.text     "notes"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quality_ratings", ["extraction_form_id", "study_id"], :name => "StudyData"

  create_table "registars", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "fname"
    t.string   "lname"
    t.string   "organization"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validationcode"
  end

  create_table "registry", :force => true do |t|
    t.integer  "crs_id",                               :null => false
    t.integer  "former_id"
    t.string   "form",                                 :null => false
    t.string   "name",                                 :null => false
    t.text     "authors"
    t.text     "title"
    t.text     "original_title"
    t.text     "journal"
    t.string   "year"
    t.string   "volume"
    t.string   "issue"
    t.string   "pages"
    t.string   "edition"
    t.string   "editors"
    t.string   "publisher"
    t.string   "country"
    t.string   "study_design"
    t.text     "abstract",       :limit => 2147483647
    t.string   "pubmed"
    t.string   "embase"
    t.string   "other_ids"
    t.string   "doi"
    t.string   "isbn"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "registry_data_points", :force => true do |t|
    t.string   "name",          :null => false
    t.string   "registry_name", :null => false
    t.integer  "registry_fk",   :null => false
    t.text     "value"
    t.string   "subvalue"
    t.text     "notes"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "registry_fields", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "option_flags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "secondary_publication_numbers", :force => true do |t|
    t.integer  "secondary_publication_id"
    t.string   "number"
    t.string   "number_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "secondary_publications", :force => true do |t|
    t.integer  "study_id"
    t.text     "title"
    t.text     "author"
    t.string   "country"
    t.string   "year"
    t.string   "association"
    t.integer  "display_number"
    t.integer  "extraction_form_id"
    t.string   "pmid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "journal"
    t.string   "volume"
    t.string   "issue"
    t.string   "trial_title"
  end

  add_index "secondary_publications", ["study_id"], :name => "secondarypublication_study_idx"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "srdr_events", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.date     "eventdate"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "srdr_quality_improvement_questionnaires", :force => true do |t|
    t.string   "q1_first"
    t.string   "q1_last"
    t.string   "q1_email"
    t.string   "q1_can_followup"
    t.string   "q2"
    t.string   "q3_lead"
    t.string   "q3_collaborator"
    t.string   "q4"
    t.string   "q5"
    t.string   "q6_month"
    t.string   "q6_year"
    t.string   "q7_abstrackr"
    t.string   "q7_openmeta"
    t.string   "q7_distiller"
    t.string   "q7_covidence"
    t.string   "q7_docdata"
    t.string   "q7_eros"
    t.string   "q7_sumari"
    t.string   "q7_cast"
    t.string   "q7_rayyan"
    t.string   "q7_revman"
    t.string   "q7_other"
    t.string   "q8"
    t.string   "q9"
    t.string   "q10"
    t.string   "q11"
    t.string   "q12a"
    t.string   "q12b"
    t.string   "q13"
    t.string   "q14"
    t.string   "q14_month"
    t.string   "q14_year"
    t.string   "q15"
    t.string   "q16"
    t.string   "q17a"
    t.string   "q17b"
    t.string   "q17c"
    t.string   "q17d"
    t.string   "q17e"
    t.string   "q18"
    t.string   "q19"
    t.string   "q20a"
    t.string   "q20b"
    t.string   "q20c"
    t.string   "q20d"
    t.string   "q20e"
    t.string   "q20f"
    t.string   "q21"
    t.string   "q22"
    t.string   "q23a"
    t.string   "q23b"
    t.string   "q23c"
    t.string   "q23d"
    t.string   "q24"
    t.string   "q25"
    t.string   "q26"
    t.string   "q26_month"
    t.string   "q26_year"
    t.string   "q27a"
    t.string   "q27b"
    t.string   "q27c"
    t.string   "q28"
    t.string   "q29"
    t.string   "q30"
    t.string   "q30_month"
    t.string   "q30_year"
    t.string   "q31a"
    t.string   "q31b"
    t.string   "q31c"
    t.string   "q32"
    t.string   "q33"
    t.string   "q34"
    t.string   "q34_month"
    t.string   "q34_year"
    t.string   "q35"
    t.string   "q36"
    t.string   "q37"
    t.string   "q38"
    t.string   "q38_month"
    t.string   "q38_year"
    t.string   "q39a"
    t.string   "q39b"
    t.string   "q39c"
    t.string   "q39d"
    t.string   "q40"
    t.string   "q41"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studies", :force => true do |t|
    t.integer  "project_id"
    t.string   "study_type"
    t.integer  "creator_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "studies", ["creator_id"], :name => "study_creator_idx"
  add_index "studies", ["project_id", "id"], :name => "StudyData"
  add_index "studies", ["project_id"], :name => "study_project_idx"

  create_table "study_extraction_forms", :force => true do |t|
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "study_extraction_forms", ["study_id"], :name => "EDIT_TAB"

  create_table "study_key_questions", :force => true do |t|
    t.integer  "study_id"
    t.integer  "key_question_id"
    t.integer  "extraction_form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "study_key_questions", ["study_id"], :name => "EDIT_TAB"
  add_index "study_key_questions", ["study_id"], :name => "studykeyquestiony_study_idx"

  create_table "study_status_notes", :force => true do |t|
    t.integer  "study_id"
    t.integer  "extraction_form_id"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trial_participant_infos", :force => true do |t|
    t.string   "age"
    t.boolean  "readEnglish"
    t.boolean  "experienceExtractingData"
    t.string   "experienceLevel"
    t.string   "articlesExtracted"
    t.string   "email"
    t.string   "submissionToken"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_organization_roles", :force => true do |t|
    t.integer  "user_id"
    t.string   "role"
    t.string   "status"
    t.boolean  "notify"
    t.boolean  "add_internal_comments"
    t.boolean  "view_internal_comments"
    t.boolean  "publish"
    t.boolean  "certified"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  create_table "user_project_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "fname",                              :null => false
    t.string   "lname",                              :null => false
    t.string   "organization",                       :null => false
    t.string   "user_type",                          :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.integer  "login_count",        :default => 0,  :null => false
    t.integer  "failed_login_count", :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "perishable_token",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true

end
