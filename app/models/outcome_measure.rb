# == Schema Information
#
# Table name: outcome_measures
#
#  id                    :integer          not null, primary key
#  outcome_data_entry_id :integer
#  title                 :string(255)
#  description           :text
#  unit                  :string(255)
#  note                  :string(255)
#  measure_type          :integer          default(0)
#  created_at            :datetime
#  updated_at            :datetime
#

class OutcomeMeasure < ActiveRecord::Base
  belongs_to :outcome_data_entry, :touch=>true
  has_many :outcome_data_points, :dependent=>:destroy
end
