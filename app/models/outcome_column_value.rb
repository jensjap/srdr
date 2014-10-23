# == Schema Information
#
# Table name: outcome_column_values
#
#  id            :integer          not null, primary key
#  outcome_id    :integer
#  timepoint_id  :integer
#  subgroup_id   :integer
#  value         :string(255)
#  is_calculated :boolean
#  arm_id        :integer
#  column_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class OutcomeColumnValue < ActiveRecord::Base
	belongs_to :outcome_column, :touch=>true
end
