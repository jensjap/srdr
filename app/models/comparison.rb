# == Schema Information
#
# Table name: comparisons
#
#  id                 :integer          not null, primary key
#  within_or_between  :string(255)
#  study_id           :integer
#  extraction_form_id :integer
#  outcome_id         :integer
#  group_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  subgroup_id        :integer          default(0)
#  section            :integer          default(0)
#

class Comparison < ActiveRecord::Base
	belongs_to :study, :touch=>true
	has_many :comparison_measures, :dependent=>:destroy
	has_many :comparators, :dependent=>:destroy
	has_many :comparison_data_points, :through=>:comparison_measures

	# get_selected_timepoints_for_diagnostic_test
	# given an outcome and subgroup, determine the timepoints that should be displayed
	# in the diagnostic test results tables for each section. The sections are:
	# Descriptive Statistics (1)
	# Assuming Reference Standard (2)
	# Additional Analysis (3)
	# Note that all timepoints be used in one section should also be used in the others
	def self.get_selected_timepoints_for_diagnostic_tests(outcome,subgroup)
		
		retVal = Hash.new()
		[1,2,3].each do |section|
			tps_with_results = Comparison.find(:all, :conditions=>["outcome_id=? AND subgroup_id=? AND section=?",outcome.id, subgroup.id,section])
			tps_with_results = tps_with_results.collect{|x| x.group_id}.uniq
			retVal[section] = tps_with_results.join("_")
		end
		return retVal
	end

=begin
	# get_selected_timepoints_for_diagnostic_test
	# given an outcome and subgroup, determine which timepoints should be displayed in the the results table. 
	# If no comparisons in a given section were created yet, then all timepoints should be used. Otherwise, give 
	# only the timepoints that have comparisons in each section
	# @return [string] a hash of strings representing the timepoint ids. e.g., 3_5 means timepoints with IDs 3 and 5 should be displayed
	#                  (the hash will be indexed by section number)
	# THIS ONLY APPLIES TO RECORDS HAVING ONLY COMPARISONS THAT ALSO HAVE SECTIONS ASSOCIATED WITH THEM
    def self.get_selected_timepoints_for_diagnostic_tests(outcome,subgroup)
	  	all_tps = outcome.outcome_timepoints.collect{|x| x.id}
	  	

	  	retVal = Hash.new()
	  	

	  	[1,2,3].each do |section|
			comparisons = Comparison.find(:all, :conditions=>["outcome_id=? AND subgroup_id=? AND section IN (?)",outcome.id, subgroup.id, section])
			comparisons = comparisons.collect{|x| x.group_id}
			#comparisons = Comparison.where(:outcome_id=>outcome.id, :subgroup_id=>subgroup.id, 
			#						:extraction_form_id=>outcome.extraction_form_id, 
			#						:study_id=>outcome.study_id,:section=>section).collect{|x| x.group_id}
			unless comparisons.empty?
				retVal[section] = comparisons.join("_");
			else
				retVal[section] = ""
			end
		end
		return retVal
    end
=end

	#-------------------------------------------------------------	
	# assign_measures
	# Anytime a new comparison is created, measures need to be assigned to it. 
	# If there are no other comparisons defined for the same outcome then the defaults will be used
	# from the default_comparison_measures table
	def assign_measures
		ocid = self.outcome_id
		outcome = Outcome.find(ocid)
		outcome_type = outcome.outcome_type
		sid = self.study_id
		efid = self.extraction_form_id
		wORb = self.within_or_between
		puts "Assigning measures for outcome #{ocid} sid #{sid} efid #{efid} and wORb #{wORb}\n\n"
		# determine if there are other comparisons in this study that defined measures can be 
		# borrowed from
		comps = Comparison.where(:outcome_id=>ocid, :study_id=>sid, :extraction_form_id=>efid, :within_or_between=>wORb,:section=>self.section)
		puts "Searched for comparisons with the same credentials and found #{comps.length}\n\n"
		# a boolean to determine if previous comparisons are defined for this study and 
		# whether or not they contain measures
		no_measures = true
		
		# if there are comparisons, create the duplicate measures

		# a hack to use comparison measures for CEVG
		ef = ExtractionForm.find(efid)
		unless comps.empty? || ef.project_id.to_i == 370
			puts "Searching comparisons..."
			comps.each do |comp|
				puts "searching #{comp.id}..."
				measures = comp.comparison_measures
				if measures.length > 0
					puts "found some measures to use."
					no_measures = false
					measures.each do |m|
						ComparisonMeasure.create(:comparison_id=>self.id, :title=>m.title,
								:description=>m.description, :unit=>m.unit,:measure_type=>m.measure_type)
					end
					break if !no_measures
					puts "did not find any measures in comparison #{comp.id}\n\n"
				end
			end
		end
		# if there are none within that outcome, check the study to see if there are any in other outcomes
		# that have measures. MAKE SURE TO ONLY USE OUTCOMES THAT ARE OF THE SAME TYPE
		if no_measures && ef.project_id.to_i != 370
			outcome_ids = Outcome.where(:study_id=>self.study_id, :extraction_form_id=>self.extraction_form_id,
									    :outcome_type=>outcome_type).collect{|x| x.id}
			# determine if there are other comparisons in this study that defined measures can be 
			# borrowed from
			comps = Comparison.where(:study_id=>sid, :extraction_form_id=>efid, :outcome_id=>outcome_ids,
									 :within_or_between=>wORb, :section=>section)

			# if there are comparisons, create the duplicate measures
			unless comps.empty?
				comps.each do |comp|
					measures = comp.comparison_measures
					if measures.length > 0
						no_measures = false
						measures.each do |m|
							ComparisonMeasure.create(:comparison_id=>self.id, :title=>m.title,:description=>m.description, :unit=>m.unit,:measure_type=>m.measure_type)
						end
						break if !no_measures
					end
				end
			end
		elsif no_measures || ef.project_id.to_i == 370
			oc = Outcome.find(ocid, :select=>[:outcome_type])
			w_or_b = wORb == 'within' ? 0 : 1
			oc_type = oc.outcome_type
			oc_type = oc_type == "Time to Event" ? "survival" : oc_type.downcase
			unless ef.project_id.to_i == 370
				if ExtractionForm.is_diagnostic?(efid)
					defaults = DefaultComparisonMeasure.where(:is_default=>true, :outcome_type=>"diagnostic_#{self.section}", :within_or_between=>w_or_b)
				else
					defaults = DefaultComparisonMeasure.where(:is_default=>true, :outcome_type=>oc_type, :within_or_between=>w_or_b)
				end
			else
				defaults = DefaultCevgMeasure.where(:outcome_type=>oc_type, :results_type=>1)
			end
			defaults.each do |d|
				ComparisonMeasure.create(:comparison_id=>self.id, :title=>d.title,:description=>d.description, :unit=>d.unit,:measure_type=>d.measure_type)
			end
		end
	end # end assign_measures function
	
	# create_new_measures
	# using a list of title and descriptions for new measures, create them for the given ocde
	def self.create_new_measures(titles,descriptions,comparison_ids,within_or_between)
		titles.keys.each do |key|
			title = titles[key]
			description = descriptions[key]
			type = 0
			comparison_ids.each do |comp_id|
				ComparisonMeasure.create(:title=>title, :description=>description, 
																 :measure_type=>type, :comparison_id=>comp_id)
			end
		end
	end

	# get_user_defined_measures
	# in the event that the user had to create their own measures rather than use the defaults,
	# get the measures
	def get_user_defined_measures
		measures = ComparisonMeasure.find(:all,:conditions=>["comparison_id = ? AND measure_type = ?",self.id,0])
		return measures
	end
	
	# get an array of measures that are unique for the study based on their title
	def get_all_user_defined_measures
		# get all comparison ids for the study
		study = Study.find(:first, :conditions=>["id=?",self.study_id],:select=>["project_id"])
        project_study_ids = Study.find(:all, :conditions=>["project_id=?",study.project_id],:select=>["id"])

		comparisons = Comparison.find(:all, :conditions=>["study_id IN (?)", project_study_ids], :select=>["id"])
		# get all associated user-defined measures
		measures = ComparisonMeasure.where(:comparison_id => comparisons, :measure_type=>0)
		uniq_measures = []
		title_array = []
		measures.each_with_index do |m,i|
			if !title_array.include?(m.title)
				uniq_measures << m
				title_array << m.title
			end
		end
		
		return uniq_measures
	end
	
	#-------------------------------------------------------------	
	# save_comparison_data
	# when a user submits a comparison, create comparator objects and save the datapoints
	def self.save_comparison_data(comparators, datapoints, comparison_measures,outcome_id=0,subgroup_id=0,two_by_two=nil)
		puts '-----------------------------------\nEntered SaveComparisonData in Comparison model\n\n'
		# keep track of when we need to create a new comparator id.
		# the old id will be used as a key for the new id
		comparator_id_retVal = Hash.new();

		# indicate whether or not the results table needs to be updated, which
		# happens only when old data that could potentially have footnotes have
		# been deleted.
  		requires_table_update = false

		# get a list of comparison IDs for the table
		comparison_ids = comparison_measures.keys.uniq
		
		# for each comparison submitted
		comparison_ids.each do |c_id|
			puts "---------\nWORKING ON COMPARISON ID #{c_id}\n"
			# Find existing comparators so that we can determine if anything needs to be removed in the end
			previous_comparator_ids = Comparator.where(:comparison_id=>c_id).collect{|x| x.id}
      		#puts "Previous comparator list is #{previous_comparator_ids}\n\n"
			# For each comparator
			my_comparator_ids = []
			if datapoints.nil?
				my_comparator_ids = two_by_two.nil? ? [] : two_by_two[c_id].nil? ? [] : two_by_two[c_id].keys	
			else
				my_comparator_ids = datapoints[c_id].nil? ? [] : datapoints[c_id].keys
				puts "adding the datapoints keys: #{my_comparator_ids}"
				unless two_by_two.nil? || !my_comparator_ids.empty?  # remember to add in the diagnostic table keys just in case it's the only measure in the row
					puts "adding the two_by_two keys..."
					my_comparator_ids += two_by_two[c_id].nil? ? [] : two_by_two[c_id].keys
					puts "comparator ids is now #{my_comparator_ids}\n\n"
				end
			end
			unless my_comparator_ids.empty?
				puts "The comparators were not empty..."
				iter = 0
				my_comparator_ids.each do |comp_id|
					#print "STARTING COMPARATOR: #{comp_id}\n"
					# Get the comparator object that we will enter measure data for
					key = comparators.keys[iter]


					# we need to determine if this is a diagnostic test comparison or 
					# a typical RCT comparison. The difference is in the format of the 
					# comparator string:
					# diagnostic test = 1|2_3|4   (test|threshold _vs_ test|threshold)
					# RCT = 1_3					  (arm _vs_ arm)
					
					# if a value of '000' is found in the comparator values array, this indicates that it's an ANOVA analysis involving all arms
					# and should be stored as such.
					comparator_string = comparators[key.to_s].values.include?("000") ? "000" : comparators[key.to_s].values.join("_");
					col_comparator = nil
					if comp_id.to_i < 0
						#puts "CREATING A NEW ONE...\n"
						col_comparator = Comparator.create(:comparison_id=>c_id, :comparator=>comparator_string)
						comparator_id_retVal[comp_id.to_i] = col_comparator.id
					elsif comp_id.to_i > 0
						#puts "USING EXISTING\n"
						col_comparator = Comparator.find(comp_id)
						#puts "removing #{comp_id} from the previous_comparator_ids list\n"
						previous_comparator_ids.delete(comp_id.to_i)
						#puts "previous_comparator_ids is now #{previous_comparator_ids}\n"
						col_comparator.comparator = comparator_string
						col_comparator.save
					end
					# Get the measures that we need to save data for
					comp_measures = comparison_measures[c_id].split("_")
				  	unless comp_measures.empty?
					  	comp_measures.each do |m_id|
					  		measure = ComparisonMeasure.find(m_id)
							# check whether or not this measure requires 2x2 table data
					  		meas_is2x2 = measure.is_2x2_table?
					  		unless meas_is2x2
						  		# CODE FOR VALUES THAT ARE NOT IN A 2x2 TABLE 
						  		#puts "Adding value for measure: #{m_id}..."
						  		new_value = datapoints[c_id.to_s][comp_id.to_s][m_id.to_s]
						  		#puts  "value is #{new_value}\n\n"
						  		# try to find an existing datapoint
						  		dp = ComparisonDataPoint.where(:comparison_measure_id=>m_id, :comparator_id=>col_comparator.id).first
						  		if dp.nil?
						  			unless new_value == ""
						  				dp = ComparisonDataPoint.create(:comparison_measure_id=>m_id, :comparator_id=>col_comparator.id,
						  																				:value=>new_value )
									end
						  	    #puts "Had to create a new datapoint object.\n\n"
								else
									dp.value = new_value
									dp.save
									#print "Used a pre-existing object and saved the changes.\n\n"
								end # end if dp.nil?
							else
								# CODE FOR VALUES THAT ARE IN A 2x2 TABLE 
								#puts "Adding values for the 2x2 table"
								# get the list of values from the parameters
								values_hash = two_by_two[c_id.to_s][comp_id.to_s][m_id.to_s]
								unless values_hash.keys.empty?
									values_hash.keys.each do |table_cell|
										new_value = values_hash[table_cell]
										#puts "the key is #{table_cell} and the value is #{new_value}"
										dp = ComparisonDataPoint.where(:comparison_measure_id=>m_id, :comparator_id=>col_comparator.id,:table_cell=>table_cell).first
										#puts dp.nil? ? "DP IS NIL" : "FOUND DP #{dp.id}\n\n"
										if dp.nil?
											#puts "since it's nil, must create a new dx result for value #{new_value}\n"
											unless new_value == ""
												dp = ComparisonDataPoint.create(:comparison_measure_id=>m_id, :comparator_id=>col_comparator.id,:table_cell=>table_cell, :value=>new_value)
												#puts "created a new objec tand the value is #{dp.id}"
											end
										else
											dp.value = new_value
											dp.save
										end
									end
								end
							end
						end # end comp_measures.each do
					end# end unless comp_measures.empty?
					iter += 1	
				end # end my_comparator_ids.each do
			end # end unless my_comparator_ids.empty?
			# If there were any comparators previously in the table that were missing when it was saved,
			# then that means the column was deleted and so we'll delete that comparator and data points
			# associated with it.
			#print "NOW I'M GOING TO DELETE THE PRE-EXISTING, AND THERE ARE #{previous_comparator_ids.length} OF THEM\n\n"
	  		previous_comparator_ids.each do |id|
	  			old_data = ComparisonDataPoint.where(:comparator_id=>id)
		  		unless old_data.empty?
		  			old_data.each do |dp|
		  				if dp.footnote_number > 0
		  					requires_table_update = true
		  					OutcomeDataEntry.update_footnote_numbers_on_delete(dp.footnote_number, outcome_id, subgroup_id)
		  				end
		  				dp.destroy
		  			end
		  		end
	  			Comparator.destroy(id)
	  		end
		end	# end comparison_ids.each do  		
		return comparator_id_retVal, requires_table_update
	end
	
    #-------------------------------------------------------------
	# save_within_arm_comparison_data
	# given a list of within arm comparisons and within-arm comparators, save
	# the data to the database.
	def self.save_within_arm_comparison_data datapoints, comparators
		# get the comparison ids from the wac_datapoints hash
		comp_ids = datapoints.keys
		comp_ids.each do |comp_id|
			# ---------- FIRST TAKE CARE OF THE COMPARATOR ---------------#
			# get comparators previously saved for this comparison
			previous_comparator_ids = Comparator.where(:comparison_id=>comp_id).collect{|x| x.id}
			
			# now get the comparator id associated with this comparison
			orig_comparator_id = comparators[comp_id].keys.first.to_i
			new_comparator_id = ""
			comparator_string = comparators[comp_id][orig_comparator_id.to_s].values.join("_")
			# if the comparator id is negative, create the new comparator
			if orig_comparator_id < 0
				tmp = Comparator.create(:comparison_id=>comp_id, :comparator=>comparator_string)
				new_comparator_id = tmp.id
			# otherwise just assign the new_comparator_id = to the original and update the comparator
			elsif orig_comparator_id > 0
				tmp = Comparator.find(orig_comparator_id)
				tmp.comparator = comparator_string
				tmp.save
				new_comparator_id = orig_comparator_id
				previous_comparator_ids.delete(new_comparator_id)
			end
			# ---------- NOW ADD THE DATA POINTS  ---------------#
			# get the measure ids associated with this comparator
			measures = datapoints[comp_id][orig_comparator_id.to_s].keys
			# cycle through the measures 
			measures.each do |m|
				# now cycle through the arm ids
				arms = datapoints[comp_id][orig_comparator_id.to_s][m].keys
				arms.each do |a|
					dp_val = datapoints[comp_id][orig_comparator_id.to_s][m][a]
					tmpDP = nil
					if orig_comparator_id > 0
				  	#if the orig_comparator is greater than 0, determine if the datapoint already exists
				  	tmpDP = ComparisonDataPoint.where(:comparison_measure_id=>m, :comparator_id=>orig_comparator_id, :arm_id=>a).first
				  	# if it does, update it and save
				  	unless tmpDP.nil?
				  		tmpDP.value = dp_val
				  		tmpDP.save
				  	# otherwise, create it
				  	else
				  		tmpDP = ComparisonDataPoint.create(:comparison_measure_id=>m, :comparator_id=>new_comparator_id, :arm_id=>a, :value=>dp_val)
				  	end
				  else
				  	# if the comparator didn't exist then the datapoint didn't either, so create it
				  	tmpDP = ComparisonDataPoint.create(:comparison_measure_id=>m, :comparator_id=>new_comparator_id, :arm_id=>a, :value=>dp_val)
				  end	
				end # end arms.each do
			end # end measures.each do 
			
			# finally, remove any comparators that are no longer being used
			unless previous_comparator_ids.empty?
				previous_comparator_ids.each do |pcid|
					Comparator.destroy(pcid)
				end
			end
		end # end comp_ids.each do
	end # end save_within_arm_comparison_data
	
	#-------------------------------------------------------------
	# update_measures
	# given a list of measures saved and those saved previously, update the measures for a given 
	# comparison
	def self.update_measures(measures,comparison_id,previous,measure_type="default")
		# keep track of previously saved information so we know what to delete
		previous = previous.split("_")
		puts "PREVIOUS IS #{previous}\n\n"
		unless measures.empty?
			# keys include the default measure id and study measure id separated by a '_'
			measures.keys.each do |key|
				puts "------\nWORKING ON KEY #{key}\n\n"
				keyParts = key.split("_")
				new_id = keyParts[0]
				prev_id = keyParts[1]
				puts "PREVID IS #{prev_id}\n\n"
				if prev_id == "0"
					unless measure_type == "user-defined"
						measure = DefaultComparisonMeasure.find(new_id)
					else
						measure = ComparisonMeasure.find(new_id)
					end
					ComparisonMeasure.create(:comparison_id=>comparison_id, :title=>measure.title, :description=>measure.description,
																	 :unit=>measure.unit, :measure_type=>measure.measure_type)
				else
				  puts "NEED TO GET RID OF A PREVIOUS ENTRY (#{prev_id})...\n\n"
				  unless previous.empty?
						previous.delete_at(previous.index(prev_id))
						puts "PREVIOUS IS NOW #{previous}\n\n"
						puts "Done.\n------\n\n"
					end
				end	
			end
		end
		# Now remove any previous ones that weren't chosen this time.
		# Calling destroy will also remove associated data points due to the model assignments
		puts "NOW CHECK FOR THOSE THAT NEED TO BE DELETED: #{previous}\n\n"
		unless previous.empty?
			puts "The list of previous measures is not empty.\n\n"
			previous.each do |prev|

			  p = ComparisonMeasure.find(prev)
			  p.destroy	
			end
		end
	end
	
	# update_measures_for_all
	# given a list of measures saved, update the measures for all comparison objects for this outcome/study/extraction form 
	def self.update_measures_for_all(measures, ocid, efid, sid, comparison_type,sgid,measure_type='default', section=0 )
		section_search = section==0 ? [0,nil] : section # Handle when we get diagnostic test comparisons
		entries = Comparison.where(:outcome_id=>ocid, :subgroup_id=>sgid, :extraction_form_id=>efid, :study_id=>sid, :within_or_between=>comparison_type, :section=>section_search)
		unless measures.empty?
			entries.each do |entry|		
				previous = []
				if measure_type == 'user-defined' 
					previous = ComparisonMeasure.find(:all,:conditions=>["comparison_id = ? AND measure_type = ?", entry.id, 0])
				else
					previous = ComparisonMeasure.find(:all,:conditions=>["comparison_id = ? AND measure_type <> ?", entry.id, 0])
				end
				previous_titles = previous.collect{|x| x.title}
				measures.keys.each do |key|
					meas_id = key.split("_")[0]
					if measure_type == 'user-defined'
						measure = ComparisonMeasure.find(meas_id)
					else
						measure = DefaultComparisonMeasure.find(meas_id)
					end
					if previous_titles.include?(measure.title)
						previous.delete_at(previous_titles.index(measure.title))
						previous_titles.delete_at(previous_titles.index(measure.title))
					else
						ComparisonMeasure.create(:comparison_id=>entry.id, :title=>measure.title, :description=>measure.description, :unit=>measure.unit, :measure_type=>measure.measure_type)
					end
				end
				unless previous.empty?
					previous.each do |p|
						p.destroy();
					end
				end	
			end
		else
			# find all comparison measures for the entries and remove them
			entry_ids = entries.collect{|x| x.id}
			# only do this for user-defined methods. we won't allow users to delete all default measures from a comparison
			if measure_type == 'user-defined'
				previous = ComparisonMeasure.find(:all,:conditions=>["comparison_id in (?) AND measure_type = ?", entry_ids, 0])
			
				previous.each do |p|
					p.destroy()
				end
			else
				previous = ComparisonMeasure.find(:all,:conditions=>["comparison_id in (?) AND measure_type = ?", entry_ids, 1])
				previous.each do |p|
					p.destroy()
				end
			end
		end
	end    
end
