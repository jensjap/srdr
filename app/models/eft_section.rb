# == Schema Information
#
# Table name: eft_sections
#
#  id                          :integer          not null, primary key
#  extraction_form_template_id :integer
#  section_name                :string(255)
#  included                    :boolean
#

class EftSection < ActiveRecord::Base
	belongs_to :extraction_form_template
end
