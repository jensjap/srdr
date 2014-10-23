# == Schema Information
#
# Table name: data_requests
#
# user_id		:integer	
# project_id	:integer
# status		:integer
# requested_at  :integer
# updated_at	:datetime
# last_downloaded_at :datetime
# download_count :integer
class DataRequest < ActiveRecord::Base
belongs_to :projects
belongs_to :users
	
end
