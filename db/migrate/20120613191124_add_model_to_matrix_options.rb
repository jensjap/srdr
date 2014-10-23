class AddModelToMatrixOptions < ActiveRecord::Migration
  def self.up
  	change_table :matrix_dropdown_options do |t|
  		t.string :model_name
  	end
  end

  def self.down
  end
end
