# == Schema Information
#
# Table name: key_questions
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  question_number :integer
#  question        :text
#  created_at      :datetime
#  updated_at      :datetime
#

# This model handles creation of key questions. A key question is specified by a 
# particular project, and then is associated with a project's extraction form. A project can have many key questions,
# and a key question can be associated with one extraction form. (An extraction form can "answer" many key questions.)
#
# A key question is linked to a study via the "study_key_questions" table which contains the fields study_id, key_question_id, 
# and extraction_form_id. This table links key questions to studies via extraction form (A study has a non-unique extraction_form_id).
class KeyQuestion < ActiveRecord::Base
	belongs_to :project, :touch=>true
	has_many :extraction_form_key_questions, :dependent=>:destroy	
	has_many :study_key_questions
	has_many :studies, :through=>:study_key_questions
	validates :question, :presence => true 

	
	# get the next display/ordering number in the sequence for a new key question
	# @param [integer] project_id
	# @return [integer] the next number in the sequence
	def get_question_number(project_id)
		current_max = KeyQuestion.maximum("question_number",:conditions => ["project_id = ?",project_id])
	  if (current_max.nil?)
	  	current_max = 0
	  end
		return current_max + 1
	end
	
	# shift the numbers for key questions for a current project based on the number that calls this function. 
	# @param [integer] project_id
	def shift_question_numbers(project_id)
		myNum = self.question_number
		higher_questions = KeyQuestion.find(:all, :conditions => ["project_id = ? AND question_number > ?", project_id, myNum])
		higher_questions.each { |question|
		  tmpNum = question.question_number
		  question.question_number = tmpNum - 1
		  question.save 
	  }
	end
	
	# remove a key question from a study
	def remove_from_junction
		skqs = StudyKeyQuestion.where(:key_question_id=>self.id)
		unless skqs.empty?
			skqs.each do |skq|
				skq.destroy		
			end
		end
	end
	
	# format the key question numbers for displaying in a string. 
	# returns something like "1, 2, and 3"
	# @param [array] questions
	# @return [string] the resulting formatted string
	def self.format_for_display(questions)
		kq_string = ""
		i = 1

		questions.each do |kq|
			if !kq.nil?
				if(i < (questions.length - 1))
					kq_string = kq_string + kq.question_number.to_s + ", "
				elsif( i < questions.length )
					kq_string = kq_string + kq.question_number.to_s + " and " 
				else
					kq_string = kq_string + kq.question_number.to_s
				end
			end
		i = i+1
		end
		return(kq_string)

	end
	
	# increment display number (ordering number) of a key question based on the key question id
	# @param [integer] id key question id
	# @param [integer] project_id
	def self.move_up_this(id, project_id)
		@this = KeyQuestion.find(id.to_i)
		if @this.question_number > 1
			new_num = @this.question_number - 1
			KeyQuestion.decrease_other(new_num, project_id)
			@this.question_number = new_num
			@this.save
		end
	end
	
	# decrement display number (ordering number) of a key question. 
	# used in move_up_this(id, project_id)
	# @param [integer] num the display number to decrement
	# @param [integer] project_id		
	def self.decrease_other(num, project_id)
		@other = KeyQuestion.where(:project_id => project_id,:question_number => num).first
		if !@other.nil?
			@other.question_number = @other.question_number + 1;
			@other.save
		end
	end
	
	# get the id for an extraction form based on the key question parameter
	# @param [integer] kq_id
	# @return [integer] the relevant extraction form id
	def self.get_extraction_form_id kq_id
		record = ExtractionFormKeyQuestion.where(:key_question_id=>kq_id).select("extraction_form_id")
		efid = record.collect{|rec| rec.extraction_form_id}[0]
		return efid
	end
  	
	# given a list of key questions, return an associative array defining whether or not
	# the question can be assigned in studies. It can be assigned if it has an associated 
	# extraction form
	# @param [array] questions_array the array of key questions
	# @return [array] an array of booleans dependent on whether the key question has an extraction form associated with it
	def self.has_extraction_form_assigned questions_array
		retVal = Hash.new
		questions_array.each do |q|
			tmp = ExtractionFormKeyQuestion.where(:key_question_id => q.id)
			if tmp.empty?
				retVal[q.id] = false
			else
				begin
					ef = ExtractionForm.find(tmp.first.extraction_form_id)
					if ef.is_ready == false
						retVal[q.id] = false
					else
						retVal[q.id] = true
					end
				rescue 
					puts '\n\nERROR: Problem finding an extraction form in key_question.has_extraction_form_assigned.\n\n'
					retVal[q.id] = false
				end
			end
		end
		return retVal
	end
	
	# check whether an extraction_form exists that uses this KQ
	# used for alerting users when editing
	# @param [integer] id the key question id
	# @return [string] a string of "true" or "false" based on whether the key question has an extraction form associated with it
	def self.has_extraction_form(id)
		eforms = ExtractionFormKeyQuestion.where(:key_question_id => id).all
		if eforms.nil? || (eforms.length == 0)
			return "false"
		else
			return "true"
		end
	end	
	
end
