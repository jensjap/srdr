# == Schema Information
#
# Table name: eft_quality_dimension_fields
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  field_notes                 :text
#  extraction_form_template_id :integer
#

class EftQualityDimensionField < ActiveRecord::Base
	belongs_to :extraction_form_template
end
