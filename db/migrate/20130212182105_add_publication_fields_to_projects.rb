class AddPublicationFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :contributors, :text
    add_column :projects, :methodology, :text
  end

  def self.down
    remove_column :projects, :methodology
    remove_column :projects, :contributors
  end
end

# ALTER TABLE `production`.`projects` ADD COLUMN `contributors` TEXT AFTER `is_public`
# ALTER TABLE `production`.`projects` ADD COLUMN `methodology` TEXT AFTER `is_public`
