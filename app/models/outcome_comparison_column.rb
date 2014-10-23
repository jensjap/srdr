# == Schema Information
#
# Table name: outcome_comparison_columns
#
#  id                 :integer          not null, primary key
#  column_header      :string(255)
#  outcome_type       :string(255)
#  column_name        :string(255)
#  column_description :string(255)
#  extraction_form_id :integer
#  study_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class OutcomeComparisonColumn < ActiveRecord::Base

	validates :column_name, :presence => true

	#has_study_data
	#check whether a study has been created that uses this extraction_form_arm name
	#used for alerting users when editing
	def self.has_study_data(id)
		datapoints = OutcomeComparisonResult.where(:outcome_comparison_column_id => id).all
		if datapoints.nil? || (datapoints.length == 0)
			return "false"
		else
			return "true"
		end
	end		
	
	
	
end
