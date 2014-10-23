# == Schema Information
#
# Table name: eft_adverse_event_columns
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  description                 :string(255)
#  extraction_form_template_id :integer
#

class EftAdverseEventColumn < ActiveRecord::Base
	belongs_to :extraction_form_template
end
