# == Schema Information
#
# Table name: outcome_timepoints
#
#  id         :integer          not null, primary key
#  outcome_id :integer
#  number     :string(255)
#  time_unit  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OutcomeTimepoint < ActiveRecord::Base
	belongs_to :outcome, :touch=>true
	attr_accessible :number, :time_unit, :outcome_id, :created_at, :updated_at
	validates :number, :presence => true, :allow_blank => false
	validates :time_unit, :presence => true
	
	def self.get_title(id)
		begin
			if id.to_i > 0
				@timepoint = OutcomeTimepoint.find(id)
				return @timepoint.number.to_s + " " + @timepoint.time_unit
			else
				return nil
			end
		rescue
			return nil
		end
	end
	
	def self.baseline_timepoint_exists(outcome_id)
		@exists = OutcomeTimepoint.where(:outcome_id => outcome_id, :number => 0, :time_unit => "baseline").first
		if @exists.nil?
			return false
		else 
			return true
		end
	end

	# has_data
	# does this timepoint have any results data associated with it?
	# @params [integer] tp_id   - the id of the timepoint in question
	# @return [boolean] retVal  - does it have data?
	def self.has_data tp_id
		retVal = false
		ocdes = OutcomeDataEntry.find(:all, :conditions=>["timepoint_id=?",tp_id],:select=>["id"])
		ocdes.each do |ocde|
			retVal = true unless ocde.outcome_data_points.empty?
		end
		return retVal
	end


	
end
