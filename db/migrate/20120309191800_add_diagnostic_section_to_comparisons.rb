class AddDiagnosticSectionToComparisons < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :section, :default=>0
  	end
  end

  def self.down
  end
end
