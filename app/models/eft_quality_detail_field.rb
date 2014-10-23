# == Schema Information
#
# Table name: eft_quality_detail_fields
#
#  id                             :integer          not null, primary key
#  eft_quality_detail_id :integer
#  option_text                    :string(255)
#  subquestion                    :string(255)
#  has_subquestion                :boolean
#  row_number                     :integer          default(0)
#  column_number                  :integer          default(0)
#

class EftQualityDetailField < ActiveRecord::Base
  belongs_to :eft_quality_detail
end
