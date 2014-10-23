class CreateSrdrEvents < ActiveRecord::Migration
  def self.up
    create_table :srdr_events do |t|
      t.string :title
      t.string :description
      t.date :eventdate
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :srdr_events
  end
end
