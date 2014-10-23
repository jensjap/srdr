# == Schema Information
#
# Table name: eft_quality_rating_fields
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  rating_item                 :string(255)
#  display_number              :integer
#

class EftQualityRatingField < ActiveRecord::Base
	belongs_to :extraction_form_template
end
