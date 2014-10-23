class AddShowSubquestionBooleanToDesignDetailFields < ActiveRecord::Migration
  def self.up
  	remove_column(:design_detail_fields, :options_with_subquestions)
  	change_table :design_detail_fields do |t|
  		t.boolean :has_subquestion
  		t.string :instruction
  	end
  end

  def self.down
  end
end
