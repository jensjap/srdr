class FixArmDetailIdField < ActiveRecord::Migration
  def self.up
  	rename_column :arm_detail_fields, :design_detail_id, :arm_detail_id
  end

  def self.down
  end
end
