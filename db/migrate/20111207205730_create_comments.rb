class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :item_table
      t.integer :item_id
      t.text :comment_text
      t.integer :commenter_id
      t.string :fact_or_opinion
      t.string :post_type
      t.boolean :is_public
      t.boolean :is_reply
      t.integer :reply_to
      t.text :value_at_comment_time
      t.boolean :is_flag
      t.string :flag_type
      t.boolean :is_high_priority

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
