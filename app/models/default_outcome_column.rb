# == Schema Information
#
# Table name: default_outcome_columns
#
#  id                 :integer          not null, primary key
#  column_name        :string(255)
#  column_description :string(255)
#  column_header      :string(255)
#  outcome_type       :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

# @deprecated
# can be deleted?
class DefaultOutcomeColumn < ActiveRecord::Base
end
