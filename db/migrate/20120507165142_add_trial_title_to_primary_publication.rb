class AddTrialTitleToPrimaryPublication < ActiveRecord::Migration
  def self.up
    add_column :primary_publications, :trial_title, :string
  end

  def self.down
    remove_column :primary_publications, :trial_title
  end
end
