class FixTheWithinOrBetween < ActiveRecord::Migration
  def self.up
  	remove_column(:comparison_data_points, :within_or_between)
  	add_column(:comparison_data_points, :within_or_between, :string)
  end

  def self.down
  end
end
