class AddNumEnrolledToArms < ActiveRecord::Migration
  def self.up
	add_column :arms, :default_num_enrolled, :integer
  end

  def self.down
	remove_column :arms, :default_num_enrolled  
  end
end
