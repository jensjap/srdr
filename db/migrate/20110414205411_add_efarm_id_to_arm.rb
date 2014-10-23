class AddEfarmIdToArm < ActiveRecord::Migration
  def self.up
  	change_table :arms do |t|
  		t.integer :efarm_id
  	end
  end

  def self.down
  end
end
