class UpdateComparisonsTypeField < ActiveRecord::Migration
  def self.up
  	change_column(:comparison_data_points, :within_or_between, :string)
  	change_table :comparison_data_points do |t|
  		t.timestamps
  	end

  end

  def self.down
  end
end
