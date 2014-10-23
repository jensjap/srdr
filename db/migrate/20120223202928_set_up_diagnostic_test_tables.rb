class SetUpDiagnosticTestTables < ActiveRecord::Migration
  def self.up
  	# add the boolean is_diagnostic to the extraction forms table
  	change_table :extraction_forms do |t|
  		t.boolean :is_diagnostic, :default=>false
  	end

  	# create a table to hold suggested diagnostic tests
  	create_table :extraction_form_diagnostic_tests do |t|
  		t.integer :test_type
  		t.string :title
  		t.text :description
  		t.text :notes
  	end

  	# create a table to hold template diagnostic tests when the form is sent to the bank
  	create_table :eft_diagnostic_tests do |t|
  		t.integer :extraction_form_template_id
  		t.integer :test_type
  		t.string :title
  		t.text :description
  		t.text :notes
  	end

  	# create a table to hold extracted diagnostic tests
  	create_table :diagnostic_tests do |t|
  		t.integer :study_id
  		t.integer :extraction_form_id
  		t.integer :test_type
  		t.string :title
  		t.text :description
  		t.text :notes
  	end

  	# create a table to hold extracted diagnostic test thresholds
  	create_table :diagnostic_test_thresholds do |t|
  		t.integer :diagnostic_test_id
  		t.string :threshold
  	end
  end

  def self.down
  	drop_table :extraction_form_diagnostic_tests
  	drop_table :eft_diagnostic_tests
  	drop_table :diagnostic_tests
  	drop_table :diagnostic_test_thresholds
  	remove_column :extraction_forms, :is_diagnostic
  end
end
