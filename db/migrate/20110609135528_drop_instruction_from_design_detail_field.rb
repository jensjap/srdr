class DropInstructionFromDesignDetailField < ActiveRecord::Migration
  def self.up
  	remove_column :design_detail_fields, :instruction
  	add_column :design_details, :instruction, :string
  end

  def self.down
  end
end
