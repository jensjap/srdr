class AddAbstractToPrimaryPublications < ActiveRecord::Migration
  def self.up
  	add_column :primary_publications, :abstract, :text
  end

  def self.down
  	remove_column :primary_publications, :abstract
  end
end
