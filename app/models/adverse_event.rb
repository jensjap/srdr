# == Schema Information
#
# Table name: adverse_events
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  title              :text
#  description        :text
#

# This model handles single adverse events, which are essentially a row in the table in the adverse event study data entry section. 
# It includes title, description, study id, and extraction form ID in order to identify a uniquely created adverse event. 
#
# An adverse event can be specified for each arm in the system, for all arms (total), or both. This option is specified in the extraction form.
# The view that handles the adverse event arm/total specification is "adverse_events/_extraction_form_settings.html.erb".
#
# An adverse event contains title and description fields by default. The adverse event may also contain a number of columns specified in the extraction form. 
# These columns are handled in the adverse_event_columns files. An adverse event table may have many rows with many custom columns. 
# Because of this each table cell data point is called an "adverse_event_result" which is specified by its column_id and adverse_event_id.
class AdverseEvent < ActiveRecord::Base
  include GlobalModelMethod

  before_save :clean_string

	belongs_to :study, :touch=>true
	has_many :adverse_event_results, :dependent=>:destroy
	
	# return adverse events depending on the arm input
	# @param [integer] arm_id
	# @return [Array] the array of adverse events
	def self.get_adverse_events_by_arm(arm_id)
		return AdverseEvent.find(:all, :conditions => ["arm_id = ?", arm_id ])
	end
	
	# get arms related to a study (based on study_id and extraction_form_id inputs)
	# @param [integer] study_id
	# @param [integer] extraction_form_id
	# @return [Array] array of arms
	def self.get_related_study_arms(study_id, extraction_form_id)
		return Arm.find(:all, :conditions => ["study_id = ? and extraction_form_id = ?", study_id, extraction_form_id], :order => "display_number ASC")
	end

end
