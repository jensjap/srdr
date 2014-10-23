# == Schema Information
#
# Table name: extraction_form_arms
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  description        :text
#  note               :string(255)
#  extraction_form_id :integer
#

# An extraction form has an 'arms' section in which the extraction form creator can "suggest" arm titles for data extractors to use.
# The titles are not binding and only show up in the drop down menu of the arms form in the study data extraction section.
class ExtractionFormArm < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
	validates :name, :presence => true
	
	# get the array of arms for a particular extraction form
	# @param [integer] efid extraction form id
	# @return [array] an array of arms and descriptions
	def self.get_arms_array(efid)
		records = ExtractionFormArm.where(:extraction_form_id=>efid).all
		descriptions = Hash.new
		records.each do |rec|
			descriptions[rec.name] = rec.description.to_s
		end
		arms = records.collect{|x| [x.name,x.name]}
			
		return [arms,descriptions]
	end
		
	# when an arm is updated in the extraction form, update all of the associated studies
	# @param [string] previous_name the old name of the arm	
	def update_studies(previous_name)
		# get information about the extraction form arm
		arm_name = self.name
		arm_description = self.description
		arm_note = self.note
		efid = self.extraction_form_id
		
		# get the studies that use this extraction form
		studies = StudyExtractionForm.where(:extraction_form_id => efid)
		
		# for each of the studies using this form, get this default arm
		unless studies.empty?
			studies.each do |study|
				# get the arm
				to_edit = Arm.where(:study_id=>study.study_id,:title=>previous_name)
				
				# unless the arm was already deleted previously
				unless to_edit.empty?
					to_edit = to_edit[0]
					
					# update the attributes
					to_edit.title = arm_name
					to_edit.description = arm_description
					to_edit.note = arm_note					
					to_edit.save
				end
			end # end studies.each
		end # end unless studies.empty?
	end # end update_studies
	
end
