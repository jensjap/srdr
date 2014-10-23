# == Schema Information
#
# Table name: extraction_form_outcome_names
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  note               :string(255)
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  outcome_type       :string(255)
#

class  ExtractionFormOutcomeName < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
	validates :title, :presence => true
	# get_outcomes_array
	# return a unique list of all outcomes that have been entered under
	# a given extraction_form
	def self.get_outcomes_array(extraction_form_id)
		ocs =  ExtractionFormOutcomeName.where(:extraction_form_id=> extraction_form_id).select(["title","note","outcome_type"])
		titles = ocs.collect{|oc| [oc.title, oc.title]}
		titles.sort!
		descriptions = Hash.new
		
		# now set up hashes to hold the description and type info based on outcome title
		if !ocs.empty?	    
			ocs.each do |oc|
				if descriptions[oc.title].nil? || descriptions[oc.title].empty?
					descriptions[oc.title] = [oc.note.nil? ? "" : oc.note, oc.outcome_type.nil? ? "Categorical" : oc.outcome_type]
				end
			end
			return [titles,descriptions]
		else
			return Array.new
		end
	end
	
	# update_studies
	# when an extraction form outcome name suggestion is updated, the changes should be
	# carried out to any studies that may have already used that name in associated
	# studies
	def update_studies(previous_title)
		outcome_title = self.title
		outcome_note = self.note
		ef_id = self.extraction_form_id
		
		# get studies associated with this extraction form
		studies = StudyExtractionForm.where(:extraction_form_id => ef_id)
		
		# for each of the studies using this form, get this default outcome
		unless studies.empty?
			studies.each do |study|

				# get the outcome
				to_edit = Outcome.where(:study_id=>study.study_id, :title=>previous_title)
				unless to_edit.empty?
					to_edit = to_edit[0]

					# update the attributes
					to_edit.title = outcome_title
					to_edit.description = outcome_note
					to_edit.save
				end
			end
		end
	end 
end
