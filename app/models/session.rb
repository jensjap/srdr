# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  session_id :string(255)      not null
#  data       :text(2147483647)
#  created_at :datetime
#  updated_at :datetime
#

class Session < ActiveRecord::Base

end
