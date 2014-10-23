# == Schema Information
#
# Table name: eft_baseline_characteristics
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  question                    :text
#  field_type                  :string(255)
#  field_notes                 :string(255)
#  question_number             :integer
#  instruction                 :text
#

class EftBaselineCharacteristic < ActiveRecord::Base
	belongs_to :extraction_form_template
	has_many :eft_baseline_characteristic_fields, :dependent=>:destroy
end
