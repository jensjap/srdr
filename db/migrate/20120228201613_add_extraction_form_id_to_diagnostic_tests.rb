class AddExtractionFormIdToDiagnosticTests < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_diagnostic_tests do |t|
  		t.integer :extraction_form_id
  	end
  end

  def self.down
  end
end
