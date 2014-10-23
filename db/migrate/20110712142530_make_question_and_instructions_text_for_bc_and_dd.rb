class MakeQuestionAndInstructionsTextForBcAndDd < ActiveRecord::Migration
  def self.up
  	change_column(:baseline_characteristics,:question, :text) 
  	change_column(:baseline_characteristics,:instruction, :text)
  	change_column(:design_details,:question, :text)
  	change_column(:design_details,:instruction, :text)
  end

  def self.down
  end
end
