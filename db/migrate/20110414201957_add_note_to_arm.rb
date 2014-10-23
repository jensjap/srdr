class AddNoteToArm < ActiveRecord::Migration
  def self.up
  	change_table :arms do |t|
  		t.string :note
  	end
  end

  def self.down
  end
end
