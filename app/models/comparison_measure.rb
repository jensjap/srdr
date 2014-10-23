# == Schema Information
#
# Table name: comparison_measures
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  description   :text
#  unit          :string(255)
#  note          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  comparison_id :integer
#  measure_type  :integer          default(0)
#

class ComparisonMeasure < ActiveRecord::Base
	has_many :comparison_data_points, :dependent=>:destroy
	belongs_to :comparison, :touch=>true
	
	# determine if the measure should be rendered as a 2x2 table
	def is_2x2_table?
		retVal = self.title == "2x2 Table" && self.description == "The standard 2x2 table"
		return retVal
	end

	# given an array of comparison measure IDs, determine if there are any corresponding values
	# returns retVal:  an associative array with measure ID as key that points to the comparison data point
	def self.get_data_points measures_array
		retVal = Hash.new
		
		unless measures_array.empty?
			measures_array.each do |measure|
				dp = ComparisonDataPoint.where(:comparison_measure_id=>measure)
				unless dp.empty?
					retVal[measure] = dp.first
				end
			end
		end
		return retVal
	end
	
	# Obtain any previous measures that were used for a particular study
	def self.get_previous_measures study_id
		all_measures = Array.new
		comparisons = Comparison.where(:study_id=>study_id)
		
		unless comparisons.empty?   # for all comparisons in this study...
			comparisons.each do |comp|
				# gather all measures for this comparison
				existing = ComparisonMeasure.where(:comparison_id=>comp.id).select(["title","description","unit"])
				unless existing.empty?
					existing.each do |em|
						tmpHash = Hash.new
						tmpHash["title"] = em.title
						tmpHash["unit"] = em.unit
						tmpHash["description"] = em.description
						all_measures << tmpHash
					end					
				end
			end
		end
		retVal = []
		unless all_measures.empty?
			retVal = all_measures.uniq
		end
		return retVal
	end
end
