# == Schema Information
#
# Table name: complete_study_sections
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  flagged_by_user    :integer
#  is_complete        :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  section_name       :string(255)
#

class CompleteStudySection < ActiveRecord::Base
	belongs_to :study, :touch=>true

	# generate_entries
	# When a section is added to an extraction form, generate the corresponding complete_study_section
	# entries in the database for all studies using that form
	# @params ef_id           - the ID for the extraction form we're working with
	# @params section_name    - an array of the names of the sections being included
	def self.generate_entries(ef_id, section_names)
		study_ids = StudyExtractionForm.find(:all, :conditions=>["extraction_form_id = ?",ef_id],:select=>["study_id"])
		study_ids = study_ids.empty? ? [] : study_ids.collect{|x| x.study_id}
		# create an entry for each existing study and section name pair
		study_ids.each do |sid|
			section_names.each do |sn|				
				CompleteStudySection.create(:study_id=>sid, :extraction_form_id=>ef_id, :is_complete=>false, :section_name=>sn)
			end
		end
	end

	# remove_entries
	# When a section is removed from an extraction form, remove the corresponding complete_study_section
	# entries from the database for all studies using that form
	# @params ef_id           - the ID for the extraction form we're working with
	# @params section_name    - an array of the names of the sections being removed
	def self.remove_entries(ef_id, section_names)
		entries = CompleteStudySection.find(:all, :conditions=>["extraction_form_id=? AND section_name IN (?)", ef_id, section_names], :select=>["id"])
		entries = entries.empty? ? [] : entries.collect{|x| x.id}
		CompleteStudySection.destroy(entries)
	end

	# assign_form_to_study
	# Given an extraction form and a study, find all sections activated in the form and 
	# create a complete_study_section object to represent that relationship
	# 
	# @params study_id     		   - the id of the study
	# @params extraction_form_id   - the id of the extraction form
	def self.assign_form_to_study(study_id, extraction_form_id)
		sections = ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=? AND included=?",extraction_form_id, true], :select=>["section_name"])
		sections = sections.empty? ? [] : sections.collect{|x| x.section_name}
		sections = sections + ['questions','publications']
		sections.each do |sect|
			CompleteStudySection.create(:study_id=>study_id, :extraction_form_id=>extraction_form_id, :section_name=>sect, :is_complete=>false)
		end
	end

	# clear_entries_for_study_form
	# when an extraction form is unassigned from a study, we need to clear all of
	# the compelete_study_section entries from the database.
	# @params study_id             - the ID of the study
	# @params extraction_form_id   - the ID of the extraction form
	def self.clear_entries_for_study_form(study_id, extraction_form_id)
		entries = CompleteStudySection.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id, extraction_form_id],:select=>["id"])
		entries = entries.collect{|x| x.id} unless entries.empty?
		CompleteStudySection.destroy(entries)
	end
end
