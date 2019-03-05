class CreateStaleProjectReminders < ActiveRecord::Migration
  def self.up
    create_table :stale_project_reminders do |t|
      t.references :project
      t.references :user
      t.boolean :enabled, default: true
      t.datetime :reminder_sent_at, default: nil

      t.timestamps
    end
  end

  def self.down
    drop_table :stale_project_reminders
  end
end
