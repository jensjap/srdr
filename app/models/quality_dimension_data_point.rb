# == Schema Information
#
# Table name: quality_dimension_data_points
#
#  id                         :integer          not null, primary key
#  quality_dimension_field_id :integer
#  value                      :string(255)
#  notes                      :text
#  study_id                   :integer
#  field_type                 :string(255)
#  extraction_form_id         :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#

# This model handles quality dimension data points. A data point is a data item in the table cell in the Quality section of study data entry.
class QualityDimensionDataPoint < ActiveRecord::Base
  include GlobalModelMethod

  before_save :clean_string

	belongs_to :study, :touch=>true
	# get the requested data based on a particular field, study, and type of data requested (field or notes)
	# @param [QualityDimensionField] field
	# @param [integer] study_id
	# @param [String] type field (data point) or notes
	# @return [string] returns the data point or notes based on the parameters given
	def self.get_data_point(field, study_id, type)
		@qddp = QualityDimensionDataPoint.where(:quality_dimension_field_id => field.id, :study_id => study_id).first
		if @qddp.nil?
			return nil
		else
			if type == "value"
				return @qddp.value
			else
				return @qddp.notes
			end
		end
	end

	# save the data points in the table - the data point information is contained in the parameters hash from the form
	# @param [integer] study_id
	# @param [integer] extraction_form_id
	# @param [hash] params form parameters that were submitted	
	def self.save_data_points(study_id, extraction_form_id, params)
		keys = params.keys
		for key in keys
			# determine if it starts with "quality" and make sure it references a hash
			if key.starts_with? "quality_"
				field_type = key.split("_") # split the key to determine field type
				field_type = field_type[1]  # save to the field type variable
				data_hash = params[key] #get the hash of actual data
				
				if field_type == "value"
					# run through the data hash
					for field_id in data_hash.keys
						unless field_id == 0 # WHY IS AN ENTRY WITH AN ID OF 0 BEING SAVED???
							value = data_hash[field_id]  # get the value being saved
							# has this field already been saved?
							qddp_exists = QualityDimensionDataPoint.where(:quality_dimension_field_id => field_id, :study_id => study_id).first
							unless qddp_exists.nil?
								# if yes, save the new info
								qddp_exists.value = value
								qddp_exists.save
							else
							  #if no, create a new object to store the info
								new_dp = QualityDimensionDataPoint.new
								new_dp.quality_dimension_field_id = field_id
								new_dp.value = value
								new_dp.study_id = study_id
								new_dp.extraction_form_id = extraction_form_id
								new_dp.save
							end
						end
					end
				else
					# run through the data hash
					for field_id in data_hash.keys
						value = data_hash[field_id]  # get the value being saved
						# has this field already been saved?
						qddp_exists = QualityDimensionDataPoint.where(:quality_dimension_field_id => field_id, :study_id => study_id).first
						unless qddp_exists.nil?
							# if yes, save the new info
							qddp_exists.notes = value
							qddp_exists.save
						else
						  #if no, create a new object to store the info
							new_dp = QualityDimensionDataPoint.new
							new_dp.quality_dimension_field_id = field_id
							new_dp.notes = value
							new_dp.study_id = study_id
							new_dp.extraction_form_id = extraction_form_id						
							new_dp.save
						end
					end			
				end
			end
		end
	end 
			
	
	

end
