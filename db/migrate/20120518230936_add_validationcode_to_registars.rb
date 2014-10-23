class AddValidationcodeToRegistars < ActiveRecord::Migration
  def self.up
    add_column :registars, :validationcode, :string
  end

  def self.down
    remove_column :registars, :validationcode
  end
end
