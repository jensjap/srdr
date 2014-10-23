# == Schema Information
#
# Table name: default_adverse_event_columns
#
#  id          :integer          not null, primary key
#  header      :string(255)
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

# @deprecated
# can be deleted?
class DefaultAdverseEventColumn < ActiveRecord::Base
end
