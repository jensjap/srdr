# == Schema Information
#
# Table name: default_quality_rating_fields
#
#  id             :integer          not null, primary key
#  rating_item    :string(255)
#  display_number :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# @deprecated
# can be deleted?
class DefaultQualityRatingField < ActiveRecord::Base
end
