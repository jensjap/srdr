# == Schema Information
#
# Table name: quality_rating_data_points
#
#  id                     :integer          not null, primary key
#  study_id               :integer
#  guideline_used         :string(255)
#  current_overall_rating :string(255)
#  notes                  :text
#  extraction_form_id     :integer
#  created_at             :datetime
#  updated_at             :datetime
#

# This model handles the data in the quality ratings section, in study data entry.
class QualityRatingDataPoint < ActiveRecord::Base
	belongs_to :study, :touch=>true
	# get the extraction form fields if the extraction form exists, otherwise return nil
	# @param [integer] study_id
	# @return [array] array of extraction form fields if there is an extraction form, otherwise nil
	def self.get_extraction_form_fields_if_extraction_form_exists(study_id)
		study = Study.find(study_id)
		extraction_form_id = study.extraction_form_id
		if !extraction_form_id.nil?
			@extraction_form = ExtractionForm.find(extraction_form_id)
			if !@extraction_form.nil?
				arr = []
				@quality_rating_extraction_form_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => @extraction_form.id}, :order => "display_number ASC")
				for field in @quality_rating_extraction_form_fields
					arr << field.rating_item
				end
				return arr
			end
		else
			return nil
		end
	end

end
