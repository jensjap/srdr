class UpdateArmsAddIsdefaultField < ActiveRecord::Migration
  def self.up
  	change_table :arms do |t|
  		t.boolean :is_suggested_by_admin, :default=>false
  	end
  	remove_column(:arms,:num_participants)
  end

  def self.down
  end
end
