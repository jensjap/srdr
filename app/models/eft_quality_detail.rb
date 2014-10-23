# == Schema Information
#
# Table name: eft_quality_details
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  question                    :text
#  field_type                  :string(255)
#  field_notes                 :string(255)
#  question_number             :integer
#  instruction                 :text
#  is_matrix                   :boolean
#  include_other_as_option     :boolean
#

class EftQualityDetail < ActiveRecord::Base
  belongs_to :extraction_form_template
  has_many :eft_quality_detail_fields, :dependent=>:destroy
end
