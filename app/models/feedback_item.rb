# == Schema Information
#
# Table name: feedback_items
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  url         :string(255)
#  page        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class FeedbackItem < ActiveRecord::Base
end
