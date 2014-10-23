class AddDefaultDisplayNumToOutcomedataentry < ActiveRecord::Migration
  def self.up
  	change_column :outcome_data_entries, :display_number, :integer, :default=>1
  end

  def self.down
  end
end
