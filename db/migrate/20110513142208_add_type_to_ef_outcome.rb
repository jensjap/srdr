class AddTypeToEfOutcome < ActiveRecord::Migration
  def self.up
  	change_table :extraction_form_outcome_names do |t|
  		t.string :outcome_type
  	end
  end

  def self.down
  end
end
