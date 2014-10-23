# == Schema Information
#
# Table name: eft_arm_details
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  question                    :text
#  field_type                  :string(255)
#  field_notes                 :string(255)
#  question_number             :integer
#  instruction                 :text
#

class EftArmDetail < ActiveRecord::Base
	belongs_to :extraction_form_template
	has_many :eft_arm_detail_fields, :dependent=>:destroy
end
