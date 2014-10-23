# == Schema Information
#
# Table name: srdr_events
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :string(255)
#  eventdate   :date
#  url         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class SrdrEvents < ActiveRecord::Base
    # Get announcements
    def getAnnouncements()
		@announcements = Comment.find(comment_id)
    end
    
    # Get upcoming events
    def getNewEvents()
    end
end
