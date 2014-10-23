# == Schema Information
#
# Table name: eft_baseline_characteristic_fields
#
#  id                             :integer          not null, primary key
#  eft_baseline_characteristic_id :integer
#  option_text                    :string(255)
#  subquestion                    :string(255)
#  has_subquestion                :boolean
#  row_number                     :integer          default(0)
#  column_number                  :integer          default(0)
#

class EftBaselineCharacteristicField < ActiveRecord::Base
	belongs_to :eft_baseline_characteristic
end
