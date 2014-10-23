# == Schema Information
#
# Table name: extraction_form_sections
#
#  id                 :integer          not null, primary key
#  extraction_form_id :integer
#  section_name       :string(255)
#  included           :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  borrowed_from_efid :integer
#

class ExtractionFormSection < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
# determine which sections were included in the extraction form
# when the extraction form was created
def self.get_included_sections(extraction_form)
	extraction_form_id = extraction_form
	list = ExtractionFormSection.where(:extraction_form_id => extraction_form_id, :included => true).all
	list = list.collect{|name| name.section_name}
	return list
end

# determine the key questions that are associated with each section
# after the section borrowing has been set up for the included
# extraction forms. 
# @return the key question assigned to the extraction form, as well as any
# assigned to forms borrowing from this section
def self.get_questions_per_section(ef_id, study_obj)
	retVal = Hash.new
	q_junction = StudyKeyQuestion.where(:study_id=>study_obj.id)
	addressed_by_study=Array.new
	unless q_junction.empty?
		q_junction.each do |question|
		  q = KeyQuestion.find(question.key_question_id, :select=>["question_number"])
		  unless q.nil?
				addressed_by_study << q.question_number
			end
		end
	end
	
	assigned_to_form = ExtractionForm.get_assigned_question_numbers(ef_id)
	assigned_to_form.each do |fid|
		unless addressed_by_study.include?(fid)
			assigned_to_form.delete_at(assigned_to_form.index(fid))
		end
	end
	form = ExtractionForm.find(ef_id)
	sections = ["arms","diagnostics","design","baselines","outcomes","results","comparisons","adverse","quality"]
	sections.each do |section|
		borrowers = form.get_borrowers(section)
		borrower_kqs = ExtractionFormKeyQuestion.find(:all, :conditions=>["extraction_form_id IN (?)",borrowers])
		borrower_kqs = borrower_kqs.collect{|kq| kq.key_question_id}
		qnums = Array.new
		borrower_kqs.each do |qid|
			kq_obj = KeyQuestion.find(qid)
			unless kq_obj.nil?
				qnums << kq_obj.question_number  unless !(addressed_by_study.include?kq_obj.question_number)
			end
		end
		retVal[section] = assigned_to_form + qnums
	end
	return retVal
end

# get sections whose information is being borrowed from a different
# extraction form in the study
def self.get_borrowed_sections(extraction_form_id)
	ef_id = extraction_form_id
	borrowed_sections = ExtractionFormSectionCopy.where(:copied_to=>ef_id)
	#borrowed_sections = ExtractionFormSectionCopy.find(:all,:conditions=>["extraction_form_id=? AND included=? AND borrowed_from_efid <> ?",ef_id,true,""])
	borrowed_sections = borrowed_sections.collect{|sec| [sec.section_name, sec.copied_from]}
	return borrowed_sections
end

# get the sections included for a given extraction form id
def self.get_included_sections_by_extraction_form_id(extraction_form_id)
	list = ExtractionFormSection.where(:extraction_form_id => extraction_form_id, :included => true).all
	list = list.collect{|name| name.section_name}
	return list
end

def self.get_first_included_ef_section(study_id)
	study_efs = StudyExtractionForm.where(:study_id => study_id).all
	if study_efs.length == 0
		return nil
	else
		for ef in study_efs
			ef_sections = ExtractionFormSection.where(:extraction_form_id => ef.extraction_form_id).all
			if ef_sections.length > 0
				for s in ef_sections
					if (s.section_name != "questions") && (s.section_name != "publications")
						arr = []
						arr << s.section_name
						arr << s.extraction_form_id
						return arr
					end
				end
			end
		end
	end
		return nil
end

def self.section_is_included(section_name, study_id, extraction_form_id)
	section = ExtractionFormSection.where(:extraction_form_id => extraction_form_id, :section_name => section_name).first
	if !section.nil?
		return section.included
	else
		return false
	end
end

def self.is_included(section_name, extraction_form_id)
	section = ExtractionFormSection.where(:extraction_form_id => extraction_form_id, :section_name => section_name).first
	if !section.nil?
		return section.included
	else
		return false
	end
end

end
