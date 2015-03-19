# == Schema Information
#
# Table name: adverse_event_results
#
#  id               :integer          not null, primary key
#  column_id        :integer
#  value            :string(255)
#  adverse_event_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  arm_id           :integer
#

# This model handles data points for adverse events. These data points are saved in the study adverse event data table.
class AdverseEventResult < ActiveRecord::Base
  include GlobalModelMethod

  before_save :clean_string

	belongs_to :adverse_event, :touch=>true
	# return an adverse event result (data point) based on adverse event id and column id inputs
	# @param [integer] ae_id adverse event id
	# @param [integer] column_id adverse event column id
	# @param [integer] arm_id arm id
	# @return [boolean]
	def self.get_data_point(ae_id, column_id, arm_id)
		if (arm_id == "total")
			arm_id = -1
		else
			arm_id = arm_id.to_i
		end
		result = AdverseEventResult.where(:adverse_event_id => ae_id, :column_id => column_id, :arm_id => arm_id).first
		if result.nil?
			return ""
		else
			return result.value
		end
	end
	
	# parse parameter string
	# formatted as: ae[X]_[Y]
	# X = adverse_event id
	# Y = adverse_event_column_id
	# @param [hash] params the parameters from the form to be saved
	def self.save_data_points(params)
		@study = Study.find(params[:study_id])
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		all_events = AdverseEvent.where(:extraction_form_id=>@extraction_form.id, :study_id=>@study.id)
		#save adverse events - title and description
		params[:title].each do |ae_id, value|
			#@adverse_event = AdverseEvent.find(ae_id)
			adverse_event = all_events.find{|a| a.id == ae_id.to_i}
			unless adverse_event.nil?
				#@adverse_event.study_id = @study.id
				#@adverse_event.extraction_form_id = @extraction_form.id
				adverse_event.title = value
				adverse_event.description = params[:description][ae_id]
				adverse_event.save
			end
		end
		
		#save adverse event column data - arm, result value, etc
		# begin with arm data
		#for item in params
		all_results = AdverseEventResult.where(:adverse_event_id => all_events.collect{|x| x.id})
		params.keys.each do |key|
			if key.starts_with? "result_"
				# initialize arm and adverse event IDs to be used for saving data points
				armID = 0
				aeID = 0
				# We found a result. Now determine if it's for a total row or a specific arm
				if key.match("total")
					# it's a total row, meaning the data is saved to arm -1 in the database.
					# EDIT: at some point these were not saving correctly. if there are multiple entries for total in one cell, remove them
					armID = -1
					aeID = key.split("_").last.to_i
				else
					keyparts = key.split("_")
					armID = keyparts[1].to_i
					aeID = keyparts[2].to_i
				end
				params[key].keys.each do |colID|
					existing_results = all_results.select{|r| r.arm_id == armID && r.adverse_event_id == aeID && r.column_id == colID.to_i}
					unless existing_results.empty?
						this_result = existing_results.first
						this_result.value = params[key][colID]
						this_result.save
						if existing_results.length > 1
							for i in 1..existing_results.length-1
								extra_result = existing_results[i]
								extra_result.destroy()
							end
						end
					else
						AdverseEventResult.create(:adverse_event_id=>aeID, :column_id=>colID.to_i, :arm_id=>armID, :value=>params[key][colID])
					end
				end
			end
		end
	end
end
=begin			
			#params[:description].each do |ae_id, value|
		#	@adverse_event = AdverseEvent.find(ae_id)
		#	adverse_event = all_events.find{|a| a.id}
		#	@adverse_event.study_id = @study.id
		#	@adverse_event.extraction_form_id = @extraction_form.id
		#	@adverse_event.description = value
		#	@adverse_event.save
		#end
			
	
			# parse each parameter element
			if (item[0].starts_with? "result_")
				parts = item[0].to_s.split("_")		
				adverse_event_id = parts[2]
				arm_id = parts[1]
				
				for elem in item[1]
					column_id = elem[0].to_i
					column_value = elem[1]
					existing = AdverseEventResult.where(:adverse_event_id => adverse_event_id, :column_id => column_id, :arm_id => arm_id).first
					if !existing.nil?
						#column value exists, update value
						existing_result = AdverseEventResult.where(:adverse_event_id => adverse_event_id, :column_id => column_id, :arm_id => arm_id).first
						existing_result.value = column_value
						existing_result.save
					else
						#column value does not exist, create new outcome result object
						new_result = AdverseEventResult.new
						new_result.adverse_event_id = adverse_event_id
						new_result.column_id = column_id
						new_result.value = column_value
						if (arm_id == "total")
							new_result.arm_id = -1
						else
							new_result.arm_id = arm_id.to_i
						end
						new_result.save
					end
				end
			end
		end
	end		
=end

