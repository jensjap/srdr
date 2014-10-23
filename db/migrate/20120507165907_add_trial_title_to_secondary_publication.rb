class AddTrialTitleToSecondaryPublication < ActiveRecord::Migration
  def self.up
    add_column :secondary_publications, :trial_title, :string
  end

  def self.down
    remove_column :secondary_publications, :trial_title
  end
end
