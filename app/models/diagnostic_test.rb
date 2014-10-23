# == Schema Information
#
# Table name: diagnostic_tests
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  test_type          :integer
#  title              :string(255)
#  description        :text
#  notes              :text
#

class DiagnosticTest < ActiveRecord::Base
	belongs_to :study, :touch=>true
	has_many :diagnostic_test_thresholds, :dependent=>:destroy
	scope :sorted_by_created_date, lambda{|efid, study_id| where("extraction_form_id=? AND study_id=?", efid, study_id).
                select(["id","test_type","title"]).
                order("created_at ASC")}
	# assign_thresholds
	# Assign threshold values when creating or updating a diagnostic test object.
	# All new values will have a negative key, while existing objects will have positive keys.
	# Also, account for those that previously existing and were deleted.
	def assign_thresholds params
		existing = DiagnosticTestThreshold.where(:diagnostic_test_id => self.id)
		existing = existing.collect{|x| x.id}
		params.keys.each do |th_id|
			if th_id.to_i < 0
				DiagnosticTestThreshold.create(:diagnostic_test_id=>self.id, :threshold=>params[th_id])
			else
				existing.delete(th_id.to_i)
				begin
					dtt = DiagnosticTestThreshold.find(th_id)
					dtt.threshold = params[th_id]
					dtt.save
				rescue Exception => e
					puts "Caught Exception:  #{e.message}\n\n"
				end
			end
		end
		# remove any of the previously existing thresholds that still remain
		existing.each do |e|
			DiagnosticTestThreshold.destroy(e)
		end
	end

	# get previously_entered_tests
	# get a list of the tests that were entered by users o
	def self.get_previously_entered_tests(ef_list, study_obj)
		index_tests, reference_tests = [Array.new, Array.new]
		index_descriptions, reference_descriptions = [Hash.new, Hash.new]
		ef_list.each do |record|
			ef_id = record.extraction_form_id

			# get suggested diagnostic tests from the form and add them to the list
			records = ExtractionFormDiagnosticTest.get_suggested_test_options(ef_id)
			index_tests += records[0]
			reference_tests += records[2]
			index_descriptions = records[1]
			reference_descriptions = records[3]
		end
		# add the default value to the descriptions lists
		index_descriptions["Choose a suggested Index Test..."] = ""
		reference_descriptions["Choose a suggested Reference Test..."] = ""
		index_descriptions["Other"] = ""
		reference_descriptions["Other"] = ""
		# pull in previous tests for the project and add those to test choices 
		# and descriptions
		previous_index_tests,previous_index_test_descriptions = Project.get_diagnostic_test_names(study_obj.project_id,1) 
		previous_reference_tests,previous_reference_test_descriptions = Project.get_diagnostic_test_names(study_obj.project_id,2) 
		index_tests += previous_index_tests
		reference_tests += previous_reference_tests
		for key in previous_index_test_descriptions.keys
			if index_descriptions[key].nil?
				index_descriptions[key] = previous_index_test_descriptions[key].strip
			end
		end
		for key in previous_reference_test_descriptions.keys
			if reference_descriptions[key].nil?
				reference_descriptions[key] = previous_reference_test_descriptions[key].strip
			end
		end

		index_tests.uniq!
		reference_tests.uniq!
		index_tests = ["Choose a suggested Index Test..."] + index_tests + ["Other"]
		reference_tests = ["Choose a suggested Reference Test..."] + reference_tests + ["Other"]
		return index_tests, index_descriptions, reference_tests, reference_descriptions
	end

	# get_select_options
	# Create an array of arrays to define select box options for the comparison selector
	# in diagnostic test results data entry. Each test should be paired with all of it's possible
	# threshold values.
	def self.get_select_options(index_tests, reference_tests, thresholds)
		
		i_tests = []
		r_tests = []
		# first capture the index and reference tests and IDs
		index_tests.each do |idx|
			unless thresholds[idx.id].nil?
				thresholds[idx.id].each do |th|
					i_tests << ["#{idx.title}--#{th.threshold}","#{idx.id}|#{th.id}"]
				end
			end
		end
		reference_tests.each do |ref|
			unless thresholds[ref.id].nil?
				thresholds[ref.id].each do |th|
					r_tests << ["#{ref.title}--#{th.threshold}","#{ref.id}|#{th.id}"]
				end
			end
		end

		# now create combinations of the index and references tests which users can choose from
		index_options = [["Choose an Index Test..",0]]
		reference_options = [["Choose a Reference Test..",0], ["Not Applicable",0]]

		i_tests.each_with_index do |a,i|
			index_options << [a[0], a[1]]
			for j in i+1..i_tests.length - 1
				b = i_tests[j]
				index_options << ["#{a[0]} AND #{b[0]}","#{a[1]}&#{b[1]}"] 
			end
		end
		
		r_tests.each_with_index do |a,i|
			reference_options << [a[0], a[1]]
			for j in i+1..r_tests.length - 1
				b = r_tests[j]
				reference_options << ["#{a[0]} AND #{b[0]}","#{a[1]}&#{b[1]}"] 
			end
		end

		
		return index_options, reference_options
	end

	# get_extraction_form_information
	# gather the following diagnostic_test-related information based on a list of extraction forms
	# associated with the study. Also gathers information re: the project
	# RETURN:
	#  - extraction_forms  (an array of extraction form objects)
	#  - diagnostic_test_descriptions (hash containing description, data type)
	#  - diagnostic_tests (an array of outcomes from the extraction forms and project)
	#  - included_sections (hash stating which sections are included for each form)
	#  - borrowed_section_names (hash stating the names of sections being borrowed in each form)
	#  - section_donor_ids  (hash providing the donor id for any section borrowing data from another)
	# PARAMS: 
	#  - ef_list    : the result of querying StudyExtractionForm for the study id
	#  - study_obj  : rails object representing the study
	#  - proj_id    : the project id
	def self.get_extraction_form_information(ef_list, study_obj, project_id)
		# set up all of the values that we will eventualy return to the controller
		extraction_forms = Array.new
		included_sections, borrowed_section_names = [Hash.new, Hash.new]
		section_donor_ids, kqs_per_section = [Hash.new, Hash.new]
		index_descriptions, reference_descriptions = [Hash.new, Hash.new]
		
		# for each extraction form associated with the study
		ef_list.each do |record|
			ef_id = record.extraction_form_id
			
			# add the extraction form to the extraction_forms list
			tmpForm = ExtractionForm.find(ef_id)
			extraction_forms << tmpForm 
			
			# determine which sections are included, and which ones are included but borrowed
			# and add this information to the appropriate hashes
			included = ExtractionFormSection.get_included_sections(ef_id)
			borrowed = ExtractionFormSection.get_borrowed_sections(ef_id)
			included_sections[ef_id] = included
			borrowed_section_names[ef_id] = borrowed.collect{|x| x[0]}
			section_donor_ids[ef_id] = borrowed.collect{|x| x[1]}
			
			# determine which key questions are addressed in each extraction form section. The values
			# will display in the side study navigation panel as ex:  Outcome Setup [1,2,3] 
			kqs_per_section[ef_id] = ExtractionFormSection.get_questions_per_section(ef_id,study_obj)
		end	# end ef_list.each
		return [extraction_forms, included_sections, borrowed_section_names, section_donor_ids, kqs_per_section]
	end


end
