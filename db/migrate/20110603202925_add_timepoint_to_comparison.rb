class AddTimepointToComparison < ActiveRecord::Migration
  def self.up
  	change_table :comparisons do |t|
  		t.integer :group_id
  	end
  end

  def self.down
  end
end
