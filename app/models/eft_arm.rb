# == Schema Information
#
# Table name: eft_arms
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  name                        :string(255)
#  description                 :string(255)
#  note                        :string(255)
#

class EftArm < ActiveRecord::Base
	belongs_to :extraction_form_template
end
