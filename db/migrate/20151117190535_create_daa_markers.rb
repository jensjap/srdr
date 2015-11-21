class CreateDaaMarkers < ActiveRecord::Migration
  def self.up
    create_table :daa_markers do |t|
      t.string :section
      t.references :datapoint
      t.references :marker

      t.timestamps
    end
  end

  def self.down
    drop_table :daa_markers
  end
end
