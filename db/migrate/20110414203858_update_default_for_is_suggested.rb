class UpdateDefaultForIsSuggested < ActiveRecord::Migration
  def self.up
  	change_table :arms do |t|
  		t.change :is_suggested_by_admin, :boolean, :default=>false
  	end
  end

  def self.down
  end
end
