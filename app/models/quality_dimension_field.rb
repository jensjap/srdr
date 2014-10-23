# == Schema Information
#
# Table name: quality_dimension_fields
#
#  id                 :integer          not null, primary key
#  title              :text
#  field_notes        :text
#  extraction_form_id :integer
#  study_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# This model handles quality dimension fields. A quality dimension field is a row that is specified in the extraction form.
# Quality dimension fields are specified in the extraction form. 
#
# When a user enters data to a study, the quality dimensions table is set up using the get_dropdown_options function, which
# examines each quality dimension, compares it to the YML file, and if the quality_dimension.title matches the dimension
# in the YML file, sets up the dropdown menu of options based on the options in that question in the YML file.
# If the dimension does not match any of those listed, the default dropdown is created with options: Yes, No, No Data, Unsure, Not Applicable.
# These default options can be changed in the get_dropdown_options function below.
class QualityDimensionField < ActiveRecord::Base
	require 'yaml'
	validates :title, :presence => true

	# get the list of quality dimensions to display in the drop down menu in the extraction form quality tab
	# @return [array] dim_fields the list of dimension fields, formatted for a rails select menu
	def self.get_dimension_list(form_type="RCT")
		puts "THE FORM TYPE IS #{form_type}\n\n\n\n"
		@dim_fields = []	
		diagnostic_fields = ["Stard - quality for diagnostic tests","QUADAS2"]
		fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/quality_dimensions.yml'
		dimensions_file = YAML::load(File.open(fn))

		@dim_fields << ["Choose a quality dimension", "choose"]		
		if (defined?(dimensions_file) && !dimensions_file.nil?)
			# go through quality_dimensions.yml
			dimensions_file.each do |section|
				unless form_type == "diagnostic" && !diagnostic_fields.include?(section['section-title'])
					@dim_fields << ["--------" + section['section-title'] + "--------","-"]
					if defined?(section['dimensions']) && !section['dimensions'].nil?
						section['dimensions'].each do |dimension|
							@str = ""					
							@str = dimension['question'] + " ["
							@options = []
							if !dimension['options'].nil?
								dimension['options'].each do |option|
									@options << option['option']
								end
							end
							@str = @str + @options.join(", ") + "]"
							@dim_fields << [@str,@str]						
						end
						# add "add all section X dimensions" link
						 @dim_fields << ["Add all " + section['section-title'] + " Dimensions", "add all "+ section['section-title']]
					end
				end
			end
		end
		@dim_fields << ["Add other dimension not in this list", "Other"]
		return @dim_fields
	end

	

	# Read the YML file for quality dimensions and return a dropdown-formatted array based on the quality dimension selected.
	# This function works by opening the quality_dimensions.yml file, reading it and comparing quality dimension entries to the current quality dimension text.
	# When the current quality dimension is found in the list, the options are converted to an array suitable for use as a dropdown menu. 
	# If the current quality dimension is not found in the list (i.e. a custom quality dimension), an array with the options "Yes" "No" "No Data" Not Applicable" 
	# is created.
	# @param [integer] quality_dimension_id the id of the quality dimension to generate an options array for
	# @return [array] arr the array to use in the dropdown for options based on the quality dimension selected
	# NO LONGER IN USE!
	def self.get_dropdown_options(quality_dimension_id)
		@quality_dimension = QualityDimensionField.find(quality_dimension_id)
		@qd_text = @quality_dimension.title
		
		@output_array = []	
		fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/quality_dimensions.yml'
		dimensions_file = YAML::load(File.open(fn))
		@output_array << ["", ""]
		
		finished = false
		if (defined?(dimensions_file) && !dimensions_file.nil?)
			# go through quality_dimensions.yml
			dimensions_file.each do |section|
				if defined?(section['dimensions']) && !section['dimensions'].nil?
					section['dimensions'].each do |dimension|
						if !finished			
							# test if dimension['question'] equals first part of @qd_text
							if defined?(dimension['question']) && !dimension['question'].nil? && (@qd_text.starts_with?(dimension['question']))
								if !dimension['options'].nil?
									dimension['options'].each do |option|
										@output_array << [option['option'], option['option']]
									end
									@output_array << ["Other...","other"]
								end
								finished = true
							end # end compare question and yml question	
						end # end finished
					end #end section.each
				end #end 
			end
		end
		# if not finished (no match found), create a default array
		if (!finished)
			@output_array << ["Yes", "Yes"]								
			@output_array << ["No", "No"]								
			@output_array << ["Unsure", "Unsure"]								
			@output_array << ["No Data", "No Data"]								
			@output_array << ["Not Applicable", "Not Applicable"]
			@output_array << ["Other...","other"]
		end
		return @output_array
	end

	#check whether a study has been created that uses this extraction_form_arm name
	#used for alerting users when editing
	# @param [integer] id the quality dimension field id
	# @return [boolean] whether any quality dimension data points exist for that study
	def self.has_study_data(id)
		datapoints = QualityDimensionDataPoint.where(:quality_dimension_field_id => id).all
		if datapoints.nil? || (datapoints.length == 0)
			return "false"
		else
			return "true"
		end
	end	

	# get the list of quality dimensions from the section specified. 
	# the dimension name begins with "add all " and the text after that is the name of the section.
	# @param [string] dimension_title
	def self.add_all_dimensions_from_section(dimension_title, extraction_form_id)
		@section_string = dimension_title[8, dimension_title.length]
		fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/quality_dimensions.yml'
		dimensions_file = YAML::load(File.open(fn))
		if (defined?(dimensions_file) && !dimensions_file.nil?)
			# go through quality_dimensions.yml
			dimensions_file.each do |section|
				if section['section-title'] == @section_string
					if defined?(section['dimensions']) && !section['dimensions'].nil?
						section['dimensions'].each do |dimension|
							@str = " ["
							@options = []
							if !dimension['options'].nil?
								dimension['options'].each do |option|
									@options << option['option']
								end
							end
							@str = @str + @options.join(", ") + "]"							
							@new_dimension = QualityDimensionField.new		
							@new_dimension.title = dimension['question'] + @str
							@new_dimension.field_notes = dimension['description']
							@new_dimension.extraction_form_id = extraction_form_id
							@new_dimension.save							
						end
					end
				end
			end
		end
	end

	# get the list of quality dimensions to be created, and create them
	# using the question builder interface. This accounts for both individual
	# questions and all questions in a section
	# params q_id 
	#    if dimension_id = section_x, find all questions in the section with an ID of x and generate them
	#    else generate just the dimension with an ID of x 
	def self.generate_quality_dimensions(ef_id, dimension_id)
		unless dimension_id == ''
			fn = File.dirname(File.expand_path(__FILE__)) + '/../../config/quality_dimensions.yml'
	    input = YAML::load(File.open(fn))
	    
	    # if we need to create an entire section of dimensions...
	    if dimension_id.match('section_')
	    	section_id = dimension_id.split("_")[1]
	    	dimensions = input.find{|x| x['id'] == section_id.to_i}['dimensions']
	    	dimensions.each do |d|
	    		self.create_question(ef_id, d)
	    	end
	    # otherwise find the individual dimension
	    else
	    	dim = input.collect{|a| a['dimensions']}
				dim = dim.flatten 
				self.create_question(ef_id, dim.find{|x| x['id'] == dimension_id.to_i})
	    end
	  end
	end

	# given a YAML entry for a quality dimension, create a QualityDesign
	# entry in the database
	def self.create_question(ef_id, dimension=nil)
		unless dimension.nil?
			# create the QualityDetail Object
			qd = QualityDetail.new(:question=>dimension['question'], :extraction_form_id => ef_id, 
				:instruction=>dimension['description'], :is_matrix=>false, :field_type=>'select')
			qd.question_number = ExtractionForm.get_next_question_number("QualityDetail",ef_id)
			qd.save
			# save the question choices based on the dimension
    	opts = {}
    	has_subquestion = false
    	gets_subquestion = {}
    	subquestion = ""
    	unless dimension['options'].nil?
    		
    		dimension['options'].flatten.each_with_index do |o,i|
    			opts["choice_#{i+1}"] = o['option']
    			unless o['follow-up'].nil?
    				puts "FOUND THE FOLLOW UP: #{o['follow-up']}"
    				has_subquestion = true 
    				subquestion = o['follow-up']
    				gets_subquestion["#{i+1}"] = "#{i+1}"
    			end
    		end
    	end
    	puts ("Question ID is #{qd.id}\n\nHas Sub is #{has_subquestion} AND gets is #{gets_subquestion}\n\n")
			QuestionBuilder.save_question_choices(opts, qd.id, false, subquestion, gets_subquestion,
				has_subquestion, "quality_detail", "QualityDetail")  
			# QuestionBuilder.save_question_choices(params["#{@model_name}_choices"], 
			# 	@model_obj.id, false,params[:subquestion_text],params[:gets_sub],
			# 	params[:has_subquestion], @model_name, @class_name)


		end
	end
end
