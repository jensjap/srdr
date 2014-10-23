class AddProsperoAndSearchToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :prospero_id, :string, :default=>nil
  	add_column :projects, :search_strategy_filepath, :string, :default=>nil

  end

  def self.down
  	remove_column :projects, :prospero_id
  	remove_column :projects, :search_strategy_filepath
  end
end
