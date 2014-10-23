class AddIndecesForComments < ActiveRecord::Migration
  def self.up
  	add_index :comments, [:section_id, :section_name, :study_id], :name=>'comment_sectionix'
  end

  def self.down
  	remove_index :comments, :name=>'comment_sectionix'
  end
end
