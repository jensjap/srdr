# == Schema Information
#
# Table name: eft_outcome_names
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  note                        :string(255)
#  extraction_form_template_id :integer
#  outcome_type                :string(255)
#

class EftOutcomeName < ActiveRecord::Base
	belongs_to :extraction_form_template
end
