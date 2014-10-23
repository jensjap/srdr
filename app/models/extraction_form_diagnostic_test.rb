# == Schema Information
#
# Table name: extraction_form_diagnostic_tests
#
#  id                 :integer          not null, primary key
#  test_type          :integer
#  title              :string(255)
#  description        :text
#  notes              :text
#  extraction_form_id :integer
#

# this class handles arms in study data entry.
class ExtractionFormDiagnosticTest < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
	# get the array of diagnostic tests for a particular extraction form
	# @param [integer] efid extraction form id
	# @return [array] an array of arms and descriptions
	def self.get_suggested_test_options(efid)
		index_records = ExtractionFormDiagnosticTest.where(:extraction_form_id=>efid,:test_type=>1)
		reference_records = ExtractionFormDiagnosticTest.where(:extraction_form_id=>efid, :test_type=>2)
		index_descriptions = Hash.new
		reference_descriptions = Hash.new
	
		index_records.each do |test|
			index_descriptions[test.title] = test.description
		end
		reference_records.each do |test|
			reference_descriptions[test.title] = test.description
		end

		index_tests = index_records.collect{|x| x.title}
		reference_tests = reference_records.collect{|x| x.title}
			
		return index_tests, index_descriptions, reference_tests, reference_descriptions
	end
end
