# == Schema Information
#
# Table name: outcome_subgroups
#
#  id          :integer          not null, primary key
#  outcome_id  :integer
#  title       :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class OutcomeSubgroup < ActiveRecord::Base
	belongs_to :outcome, :touch=>true
	#attr_accessible :number, :time_unit, :outcome_id, :created_at, :updated_at
	#validates :number, :numericality => true, :allow_blank => true
	#validates :time_unit, :presence => true
	

	# given the id of an outcome subgroup, return the title
	# @param [integer]  sgid     - the subgroup id to search for
	# @return [string] sgtitle  - the title of the subgroup
	def self.get_title(sgid)
		begin
			sg = OutcomeSubgroup.find(sgid, :select=>[:title])
			return sg.title
		rescue
			return nil
		end
	end


	# has_data
	# does this subgroup have any results data associated with it?
	# @params [integer] sg_id   - the id of the subgroup in question
	# @return [boolean] retVal  - does it have data?
	def self.has_data sg_id
		retVal = false
		ocdes = OutcomeDataEntry.find(:all, :conditions=>["subgroup_id=?",sg_id],:select=>["id"])
		ocdes.each do |ocde|
			retVal = true unless ocde.outcome_data_points.empty?
		end
		return retVal
	end
end
