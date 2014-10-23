# == Schema Information
#
# Table name: extraction_form_adverse_events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  note               :string(255)
#  extraction_form_id :integer
#

# An extraction form has an 'arms' section in which the extraction form creator can "suggest" arm titles for data extractors to use.
# The titles are not binding and only show up in the drop down menu of the arms form in the study data extraction section.
class ExtractionFormAdverseEvent < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
	validates :title, :presence => true
	
end
