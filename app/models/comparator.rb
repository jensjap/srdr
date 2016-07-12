# == Schema Information
#
# Table name: comparators
#
#  id            :integer          not null, primary key
#  comparison_id :integer
#  comparator    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Comparator < ActiveRecord::Base
	belongs_to :comparison, :touch=>true
	has_many :comparison_data_points, :dependent=>:destroy

	# given a comparator in it's typical representation, convert it into a
	# human readable string
	# @param [string]   type  - is this between-arms or within-arms
	#	 		  					   (options for type are within, between)
	# @return [string]    title - the string representation of the comparator
	def to_string type
		title = ""
		# split the comparator into it's separate ids
		ids = self.comparator.split("_")

		# for each id segment, find the title of the object and append it to the
		# growing title. if it's a between-arm comparison, we look for an arm.
		# if it's a within-arm comparison, we look for a timepoint
		if ids.length == 1 && type == 'between'
			if ids.first == '000'
				title = 'All Arms (ANOVA)'
			end
		else
			ids.each_with_index do |id,iter|
				tmp = nil
				unless id.to_i == 0
					if type=='between'
						begin
							# in the event that there's an ampersand betwen arms, that indicates a multi-arm selection
							# used for crossover studies
							id_parts = id.split("&")
							id_parts.each do |idp|
								tmp = Arm.find(:all, :conditions=>["id IN (?)",id_parts],:select=>["title"])
								tmp = tmp.collect{|x| x.title}
							end
						rescue
							puts "couldn't find an arm with id = #{id}"
						end
					elsif type=='diagnostic'
						composites = id.split("&")
						tmpString = ""
						composites.each do |c|
							pieces = c.split("|")
							begin
								tmp1 = DiagnosticTest.find(pieces[0])
								tmp2 = DiagnosticTestThreshold.find(pieces[1])
								tmpString += "#{tmp1.title} -- #{tmp2.threshold}"
							rescue ActiveRecord::RecordNotFound
								tmpString += "ERROR"
							end
							tmpString += " AND " unless composites.index(c) == composites.length - 1
						end
						title += tmpString
					elsif type=='within'
						tmp = OutcomeTimepoint.find(id, :select=>['number','time_unit'])
					end
				end
				unless type == 'diagnostic'
					# if the class of tmp is an outcome timepoint we know it's a within arm comparison and we should return the 
					# value of the timepoint. If it's an array it could be a list of arm names that represent one half of the 
					# comparator in a between arm comparison.
					tmp = tmp.nil? ? "ERROR" : tmp.class==OutcomeTimepoint ? "#{tmp.number} #{tmp.time_unit}" : tmp.join(" AND ")
					title += tmp
				end

				unless iter == ids.length - 1
					title += " vs. "
				end
			end
		end
		return title
	end
end
