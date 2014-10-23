class ChangePubTitleFromStringToText < ActiveRecord::Migration
  def self.up
  	change_column(:primary_publications, :title, :text)
  	change_column(:secondary_publications, :title, :text)
  end

  def self.down
  end
end
