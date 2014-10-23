class CreateRegistars < ActiveRecord::Migration
  def self.up
    create_table :registars do |t|
      t.string :login
      t.string :email
      t.string :fname
      t.string :lname
      t.string :organization
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :registars
  end
end
