# == Schema Information
#
# Table name: quality_rating_fields
#
#  id                 :integer          not null, primary key
#  extraction_form_id :integer
#  rating_item        :string(255)
#  display_number     :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# This model handles the options in the quality ratings section, in extraction form creation. The default values are Good, Fair and Poor. 
# The default values are set in config/default_questions.yml.
class QualityRatingField < ActiveRecord::Base
	validates :rating_item, :presence => true

	# get the new maximum display number of the current list of quality rating items for this particular extraction form
	# @param [integer] extraction_form_id
	# @return [integer] the new display number
	def get_display_number(extraction_form_id)
	  current_max = QualityRatingField.maximum("display_number",:conditions => ["extraction_form_id = ?", extraction_form_id])
	  if (current_max.nil?)
	  	current_max = 0
	  end
		return current_max + 1
	end
	
	# shift the display numbers the current list of quality rating items for this particular extraction form, based on the rating item that calls this function.
	# @param [integer] extraction_form_id	
	def shift_display_numbers(extraction_form_id)
		puts "Shifting display numbers."
		myNum = self.display_number
		puts "Display num is #{myNum}\n"
		high_things = QualityRatingField.find(:all, :conditions => ["extraction_form_id = ? AND display_number > ?", extraction_form_id, myNum])
		high_things.each { |thing|
		  tmpNum = thing.display_number
		  tmpNum -= 1
		  puts "Updating #{thing.display_number} to #{tmpNum}\n"
		  thing.display_number = tmpNum
		  thing.save 
		  puts "Should have saved properly."
	    }
	end  

	# move up the display number (increment by 1) of the rating option given, in the extraction form given.
	# @param [integer] id quality rating field id
	# @param [integer] extraction_form_id
	def self.move_up_this(id, extraction_form_id)
		@this = QualityRatingField.find(id.to_i)
		if @this.display_number > 1
			new_num = @this.display_number - 1
			QualityRatingField.decrease_other(new_num, extraction_form_id)
			@this.display_number = new_num
			@this.save
		end
	end
	
	# decrease the display number of the rating option that has the specified number, in the extraction form given.
	# @param [integer] num the number that needs to be decreased
	# @param [integer] extraction_form_id	
	def self.decrease_other(num, extraction_form_id)
		@other = QualityRatingField.where(:extraction_form_id => extraction_form_id, :display_number => num).first
		if !@other.nil?
			@other.display_number = @other.display_number + 1;
			@other.save
		end
	end
	

	# check whether a study has been created that uses this extraction_form_arm name. 
	# used for alerting users when editing
	# @param [integer] extraction_form_id
	# @return [string] true or false based on whether the section has study data saved.
	def self.has_study_data(id)
		datapoints = QualityRatingDataPoint.where(:extraction_form_id => id).all
		if datapoints.nil? || (datapoints.length == 0)
			return "false"
		else
			return "true"
		end
	end		
  

end
