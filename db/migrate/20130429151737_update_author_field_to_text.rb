class UpdateAuthorFieldToText < ActiveRecord::Migration
  def self.up
  	change_column :primary_publications, :author, :text
  	change_column :secondary_publications, :author, :text
  end

  def self.down
  	change_column :primary_publications, :author, :string
  	change_column :secondary_publications, :author, :string
  end
end
