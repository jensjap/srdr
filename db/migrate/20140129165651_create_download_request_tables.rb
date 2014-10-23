class CreateDownloadRequestTables < ActiveRecord::Migration
  def self.up
  	create_table :data_requests do |t|
  		t.integer :user_id
  		t.integer :project_id
  		t.string :status, :default=>"pending"
      t.text :message
  		t.datetime :requested_at
      t.integer :responder_id
  		t.datetime :responded_at
  		t.datetime :last_download_at
  		t.integer :download_count, :default=>0
      t.integer :request_count, :default=>0
  	end
    #add_index(:data_requests, [:user_id, :project_id], :unique=>true)
  	add_column :projects, :public_downloadable, :boolean, {:default => false}
  end

  def self.down
  	drop_table :data_requests
  	remove_column :projects, :public_downloadable
  end
end
