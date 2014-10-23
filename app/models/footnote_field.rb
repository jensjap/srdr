# == Schema Information
#
# Table name: footnote_fields
#
#  id              :integer          not null, primary key
#  study_id        :integer
#  footnote_number :integer
#  field_name      :string(255)
#  page_name       :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class FootnoteField < ActiveRecord::Base
	belongs_to :study, :touch=>true
	# remove footnote fields for the given study id
	def self.remove_entries(sid, page_name)
		footnotes = FootnoteField.where(:study_id=>sid, :page_name=>page_name)
		unless footnotes.empty?
			footnotes.each do |fnote|
				fnote.destroy
			end
		end
	end
end
