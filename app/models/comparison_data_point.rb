# == Schema Information
#
# Table name: comparison_data_points
#
#  id                    :integer          not null, primary key
#  value                 :string(255)
#  footnote              :string(255)
#  is_calculated         :boolean
#  comparison_measure_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#  comparator_id         :integer
#  arm_id                :integer          default(0)
#  footnote_number       :integer          default(0)
#  table_cell            :integer
#

class ComparisonDataPoint < ActiveRecord::Base
	belongs_to :comparison_measure
	belongs_to :comparator, :touch=>true
	# save the results of a comparison input
	# return the div id of the matrix blocked that was selected, or nil
	def self.save_comparison(values,metrics,objects,type,comp_id)
	  
	  # determine which objects are being compared (using the ids)
	  objectsArray = []
	  objects.keys.each do |oKey|
	  	objectsArray << objects[oKey]
	  end
	  # Create a comparators string such as "3_1_2" which would mean 3 vs 1 vs 2 or "3_1" meaning 3 vs 1.
	  # In this example, "3" and "1" are IDs of either timepoints or arms.
	  # Next, add the comparators to the comparison object.
	  comparison = Comparison.find(comp_id)		
	  comparison.comparators = objectsArray.join("_")
	  
	  # save the new comparison
	  if comparison.save
	  	
	  	
	  	# set up the comparison data points based on comparison measures 
	  	i = 0
	  	metrics.keys.each do |mKey|
	  		metric_id = mKey.split("_")[1]        # get the metric id for the metric being reported
	  		
	  		# before saving, remove any existing data for this comparison
	  		search = ComparisonDataPoint.where(:comparison_measure_id=>metric_id)	
	  		unless search.empty?
	  			search.each do |entry|
	  				entry.destroy	
	  			end
	  		end
	  		   
	  		tmpCDP = ComparisonDataPoint.new         # create a new data point
	  		tmpCDP.value = values[values.keys[i]]    # get the value for the data point
	  		unless tmpCDP.value.empty?
	  			tmpCDP.comparison_measure_id = metric_id # get the associated metric of the data point
	  			tmpCDP.save
	  		end
	  		i+=1
	  	end
	  		  	
	  else
	  	
	  end
	end
end
