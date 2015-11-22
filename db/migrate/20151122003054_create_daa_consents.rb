class CreateDaaConsents < ActiveRecord::Migration
  def self.up
    create_table :daa_consents do |t|
      t.string :email
      t.string :firstName
      t.string :lastName
      t.string :qOne
      t.string :qTwo
      t.boolean :agree

      t.timestamps
    end
  end

  def self.down
    drop_table :daa_consents
  end
end
