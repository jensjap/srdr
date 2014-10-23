# == Schema Information
#
# Table name: ef_section_options
#
#  id                 :integer          not null, primary key
#  extraction_form_id :integer          not null
#  section            :string(255)
#  by_arm             :boolean          default(FALSE)
#  by_outcome         :boolean          default(FALSE)
#  include_total      :boolean          default(FALSE)
#

class EfSectionOption < ActiveRecord::Base
	# self.section_is_by_category
	def self.is_section_by_category? extraction_form_id, section_name
		retVal = false
		entry = EfSectionOption.find(:all, :conditions=>['extraction_form_id=? AND section=?',extraction_form_id,section_name],:select=>["by_arm","by_outcome","by_diagnostic_test"])
		section_category = section_name == 'quality_detail' ? 'by_outcome' : "by_#{section_name.gsub(/\_detail/,'')}"
		unless entry.empty?
			e = entry.first
			retVal = e[section_category]
		end
		return retVal
	end

	# get
	# @params   extraction_form_id        the extraction form
	# @params   section_name              the section fo interest
	# @return   rec                       either the EfSectionOption object or nil if none were found
	def self.get(extraction_form_id, section_name)
		begin
			rec = EfSectionOption.find(:first, :conditions=>["extraction_form_id=? AND section=?",extraction_form_id, section_name],
										   :select=>["id","extraction_form_id","section","by_arm","by_outcome","by_diagnostic_test"])
		rescue
			rec = nil
		end
		return rec
	end

	# set
	# @params        id          the id of the record
	# @params        column      the record column to set
	# @params        value       the value to stick in the column
	# @return        retVal      true if succeeded, false otherwise
	def self.set(id, column, value)
		retVal = true
		begin
			rec = EfSectionOption.find(id)
			rec[column] = value
			rec.save
		rescue
			retVal = false
		end
		return retVal
	end
end
