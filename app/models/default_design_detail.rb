# == Schema Information
#
# Table name: default_design_details
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  notes      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# @deprecated
# can be deleted?
class DefaultDesignDetail < ActiveRecord::Base
end
