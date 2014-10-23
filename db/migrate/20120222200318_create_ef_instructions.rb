class CreateEfInstructions < ActiveRecord::Migration
  def self.up
    create_table :ef_instructions do |t|
      t.integer :ef_id
      t.string :section
      t.string :data_element
      t.text :instructions

      t.timestamps
    end
  end

  def self.down
    drop_table :ef_instructions
  end
end
