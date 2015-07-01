# this controller handles outcome data entries in the study data entry section (?)
class OutcomeDataEntriesController < ApplicationController

	# Display the timepoint selector when users are entering data
	def show_timepoints
		ocid = params[:outcome_id]
		@outcome = Outcome.find(ocid, :select=>["id","title","description","units","study_id","extraction_form_id","outcome_type"])
		@project_id = params[:project_id]
		ef_id = params[:extraction_form_id]
		ef = ExtractionForm.find(ef_id)
		@project_id = ef.project_id 
		@is_diagnostic = ExtractionForm.is_diagnostic?(ef_id)

		unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id], :select=>["id","title","description"]) 
		else
			@subgroup = nil
		end
		
		@checkbox_timepoints = @outcome.outcome_timepoints
		
		# If this extraction form deals with RCT data...
		if !@is_diagnostic
	  		@selected_timepoints = OutcomeDataEntry.get_selected_timepoints(@outcome,@subgroup)

	  		@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
			@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
			@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
			@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

			study = Study.find(@outcome.study_id)
			@existing_results = study.get_existing_results_for_session(ef_id)
			@message_div = 'deleted_item_indicator'
			@table_container = 'existing_results_div'
			@table_partial = 'outcome_data_entries/existing_results'
			if @existing_results.empty?
				@div_to_clear = 'view_modify_link_div'
			end
			#-----------------------------------------
			# update the existing comparisons table
			#-----------------------------------------
			@existing_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(@OCDEs)

		# Otherwise, gather the diagnostic test comparison data.
		else
			if Comparison.count(:conditions=>["outcome_id=? AND subgroup_id=?", @outcome.id, @subgroup.id]) == 0
				@selected_timepoints = Hash.new()
				tps = @checkbox_timepoints.collect{|x| x.id}.join("_")
				[1,2,3].each do |sect_num|
					@selected_timepoints[sect_num] = tps
				end
			else
				@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(@outcome,@subgroup)
			end
			@outcomes = Outcome.find(:all, :conditions=>["study_id=?",@outcome.study_id], :select=>["title","id","extraction_form_id"])
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
			@outcome_id, @study_id, @extraction_form_id, @selected_tp_array, @timepoints, @comparisons, 
			@comparators, @all_comparators, @comparison_measures, @comparison_datapoints, @index_tests, 
			@reference_tests, @thresholds, @footnotes = OutcomeDataEntry.get_diagnostic_test_results(@outcome,@subgroup,@selected_timepoints)
			
			@index_test_options, @reference_test_options = DiagnosticTest.get_select_options(@index_tests,@reference_tests,@thresholds)
		end
    end
  
  # based on the outcome and timepoint selection, display the data entry table
  def show_entry_table
  	@outcome_id = params[:outcome_id]
  	@outcome = Outcome.find(@outcome_id)
  	@selected_timepoints = params[:selected_timepoints]
  	@project_id = params[:project_id]
  	unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
  	#-----------------------------------------
  	# Data for the entry table
  	#-----------------------------------------
  		@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

  end

  # given a list of selected timepoints, update the table accordingly
	def update_table_rows
	  	@outcome_id = params[:outcome_id]
	  	@outcome = Outcome.find(@outcome_id)
	  	@project_id = params[:project_id]
	  	@is_diagnostic = ExtractionForm.is_diagnostic?(@outcome.extraction_form_id)
	  	@checkbox_timepoints = @outcome.outcome_timepoints
	  	unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end

	  	# IF THIS IS A DIAGNOSTIC TEST RESULT TABLE
	  	if @is_diagnostic
	  		@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(@outcome,@subgroup)
	  		params[:tps_to_add].keys.each do |sectionNum|
	  			tpString = params[:tps_to_add][sectionNum].join("_")
	  			#puts "The original TP string is #{@selected_timepoints[sectionNum.to_i]} and the string we're adding is #{tpString}"
	  			if @selected_timepoints[sectionNum.to_i].empty?
					@selected_timepoints[sectionNum.to_i] = tpString
				else
					@selected_timepoints[sectionNum.to_i] += "_#{tpString}"
				end
				#puts "THE RESULT IS: #{@selected_timepoints[sectionNum.to_i]}\n\n"
	  		end
	  	
	  		
			@outcome_id, @study_id, @extraction_form_id, @selected_tp_array, @timepoints, @comparisons, 
			@comparators, @all_comparators, @comparison_measures, @comparison_datapoints, @index_tests, 
			@reference_tests, @thresholds, @footnotes = OutcomeDataEntry.get_diagnostic_test_results(@outcome,@subgroup,@selected_timepoints)

			@outcomes = Outcome.find(:all, :conditions=>["study_id=?",@outcome.study_id],:select=>["id","title","extraction_form_id"])
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)

			@index_test_options, @reference_test_options = DiagnosticTest.get_select_options(@index_tests,@reference_tests,@thresholds)
	  	
	  	# OTHERWISE, IF IT'S AN RCT RESULT TABLE
	  	else
	  		@selected_tp_array = params[:selected_timepoints].split("_")
	  		tps_to_add = params[:tps_to_add]
			unless tps_to_add.nil?
				@selected_tp_array = @selected_tp_array + tps_to_add
			end
			@selected_timepoints = @selected_tp_array.join("_")

			#-----------------------------------------
		  	# Data for the entry table
		  	#-----------------------------------------
		  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
			@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
			@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
			@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)	
				
		    @hide_wait_icon = true  # indicate that we need to hide a loading icon

	  	end

	    render '/outcome_data_entries/show_timepoints'
	end

  # Display the form for users to edit the measures associated with their study
	def show_measures_form
		@ocde_id = params[:ocde_id]
		@subgroup_id = params[:subgroup_id]
		@project_id = params[:project_id]
		ocde = OutcomeDataEntry.find(@ocde_id)
		@timepoint_id = params[:timepoint_id]
		outcome_type = params[:outcome_type]
		outcome_type = outcome_type == "Time to Event" ? "survival" : outcome_type
		if @project_id == 427 || @project_id == 553
			@all_measures = DefaultCevgMeasure.find(:all, :conditions=>["outcome_type = ? AND results_type=?",outcome_type, 0])
		else
			@all_measures = DefaultOutcomeMeasure.find(:all,:conditions=>["outcome_type = ? AND measure_type <> ?", outcome_type.downcase, 0])		
		end
		@selected_measures = ocde.get_measures(outcome_type)
		@all_user_defined_measures = ocde.get_all_user_defined_measures
		@selected_timepoints = params[:selected_timepoints] #indicates the timepoint in the dropdown
		@show_measures_for = "Outcome"
	end
	
	# Destroy a given entry (row) in the results table based on the OCDE id of that entry
	def destroy
	
		@selected_tp_array = params[:selected_timepoints].split("_")
		ocde_id = params[:ocde_id]                         # the outcome data entry to destroy
		ocde = OutcomeDataEntry.find(ocde_id)              # the ocde object
		@outcome = Outcome.find(ocde.outcome_id)
		# update the row display numbers (unless this ocde isn't sorted at all)
		ocde.update_display_numbers_for_deletion unless(ocde.display_number.nil? || ocde.display_number == 0)
		# remove data points and re-order footnotes if necessary
		ocde.remove_outcome_data
		ocde.remove_comparison_data                        
		unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end

		@checkbox_timepoints = @outcome.outcome_timepoints
			
		@selected_tp_array.delete(ocde.timepoint_id.to_s)
		@selected_timepoints = @selected_tp_array.join("_")
		@checkbox_ID = "#checkbox_#{ocde.timepoint_id}"
			ocde.destroy                                       # now remove the ocde and associated data points/measures
	  	@outcome_id = ocde.outcome_id
	  	@outcome = Outcome.find(@outcome_id)
	  	@checkbox_timepoints = @outcome.outcome_timepoints
	  	#-----------------------------------------
	  	# Data for the entry table
	  	#-----------------------------------------
	  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
			@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
			@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
			@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)
	  	
	  	# hack to get the project id back into the mix
	  	ef = ExtractionForm.find(@extraction_form_id)
	  	@project_id = ef.project_id
    	
    	render '/outcome_data_entries/show_timepoints'
	end
	
	# Destroy all outcome data entry objects for a given outcome and subgroup
	# pair. After completion, update the existing_results session variable to remove
	# the deleted data.
	# @param [Int] outcome_id  the id of the outcome of interest
	# @param [Int] subgroup_id   the id of the subgroup of interest
	def destroy_for_outcome_and_subgroup
		outcome_id = params[:outcome_id]
		subgroup_id = params[:subgroup_id]
		@extraction_form_id = params[:extraction_form_id]
		outcome = Outcome.find(outcome_id)
		puts "OUTCOME ID IS #{outcome_id} AND SGID IS #{subgroup_id}\n\n\n"
		key = "#{outcome_id}_#{subgroup_id}"
		@is_diagnostic = params[:is_diagnostic].blank? ? false : true
		puts "------------\nIS DIAGNOSTIC: #{@is_diagnostic}\n\n-----------\n"
		unless @is_diagnostic
			subgroup_title = OutcomeSubgroup.get_title(subgroup_id)
			outcome_title = Outcome.get_title(outcome_id)
			ocdes = OutcomeDataEntry.where(:outcome_id=>outcome_id, :subgroup_id=>subgroup_id)
			# get rid of the outcome data entry objects
			unless ocdes.empty?
				ocdes.each do |ocde|
					ocde.remove_comparison_data  # remove associated comparison data
					ocde.destroy                 # remove the data entry object
				end
			end
			study = Study.find(outcome.study_id)
			@existing_results = study.get_existing_results_for_session(@extraction_form_id)
			@message_div = 'deleted_item_indicator'
			@table_container = 'existing_results_div'
			@table_partial = 'outcome_data_entries/existing_results'
			if @existing_results.empty?
				@div_to_clear = 'view_modify_link_div'
			end
			#-----------------------------------------
			# update the existing comparisons table
			#-----------------------------------------
			@study_arms = Arm.find(:all, :conditions=>["study_id = ? AND extraction_form_id=?",study.id, @extraction_form_id], :order=>"display_number ASC", :select=>["id","title","description","display_number","extraction_form_id","note","default_num_enrolled","is_intention_to_treat"])
			@existing_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
			
		else
			puts "DOING DIAGNOSTIC STUFF"

			comparisons = Comparison.where(:outcome_id=>outcome_id, :subgroup_id=>subgroup_id)
			outcome = Outcome.find(outcome_id)
			study = Study.find(outcome.study_id)
			subgroup = OutcomeSubgroup.find(subgroup_id)
			@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(outcome,subgroup)
			comparisons.each do |comp|
				comp.destroy()
			end
			comparisons = study.get_comparison_entries
			@existing_comparisons, @existing_comparators = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)
			@message_div = 'deleted_item_indicator'
			@table_container = 'existing_results_div'
			@table_partial = 'outcome_data_entries/existing_diagnostic_results'
			if comparisons.empty?
				@div_to_clear = 'view_modify_link_div'
			end
			@outcomes = Outcome.find(:all, :conditions=>["study_id=?",outcome.study_id], :select=>["id","title","extraction_form_id"])
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
		end

    	render 'shared/saved.js.erb'
	end
	
  # Update the measures associated with this outcome data entry
	def update_measures
		apply_to = params[:changes_apply_to]
		previously_saved = params[:previously_checked]
		previously_user_defined = params[:previously_defined_checked]
		measures = params[:measures]
		user_defined_measures = params[:user_defined_measures].nil? ? [] : params[:user_defined_measures]
		# Get information in regards to any new measures that the user created
		new_measure_titles = params[:user_defined_titles]
		new_measure_descriptions = params[:user_defined_descriptions]
		
    ocde_id = params[:ocde_id]
    ocde = OutcomeDataEntry.find(ocde_id)
    unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
    if apply_to == "this"
			OutcomeDataEntry.update_measures(measures, ocde_id, previously_saved)
			OutcomeDataEntry.update_measures(user_defined_measures, ocde_id, previously_user_defined,'user-defined') unless user_defined_measures.nil?
			unless (new_measure_titles.nil?)
				OutcomeDataEntry.create_new_measures(new_measure_titles, new_measure_descriptions, [ocde_id])
			end
		elsif apply_to == "all"
			ocdes = OutcomeDataEntry.where(:study_id=>ocde.study_id, :outcome_id=>ocde.outcome_id, :extraction_form_id=>ocde.extraction_form_id)
			ocdes = ocdes.collect{|x| x.id}
			OutcomeDataEntry.update_measures_for_all(measures, ocde.outcome_id, ocde.extraction_form_id, ocde.study_id, @subgroup)
			OutcomeDataEntry.update_measures_for_all(user_defined_measures, ocde.outcome_id, ocde.extraction_form_id, ocde.study_id, @subgroup,'user-defined') unless user_defined_measures.nil?
			unless (new_measure_titles.nil?)
				OutcomeDataEntry.create_new_measures(new_measure_titles, new_measure_descriptions,ocdes)
			end
		end
  	@selected_timepoints = params[:selected_timepoints]
  	@selected_tp_array = @selected_timepoints.split("_")
  	@outcome_id = ocde.outcome_id
  	@outcome = Outcome.find(@outcome_id)
  	
  	#-----------------------------------------
  	# Data for the entry table
  	#-----------------------------------------
  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)
	end
	
  # Display the window to give users the ability to specify calculated 
  # vs non-calculated data points, as well as generate footnotes for 
  # that field.
  def show_data_point_options_form
  	@field_id = params[:field_id]
  	@outcome_id = params[:outcome_id]
  	@subgroup_id = params[:subgroup_id]
  	@outcome = Outcome.find(@outcome_id)
  	@selected_timepoints = params[:selected_timepoints]
  	@datapoint, @dp_type = OutcomeDataPoint.get_data_point_object(@field_id)
  	@is_diagnostic = ExtractionForm.is_diagnostic?(@outcome.extraction_form_id)
  	unless params[:subgroup_id].nil?
		@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
	else
		@subgroup = nil
	end
  	# If this extraction form deals with RCT data...
	if !@is_diagnostic
  		@selected_timepoints = OutcomeDataEntry.get_selected_timepoints(@outcome,@subgroup)

	# Otherwise, gather the diagnostic test comparison data.
	else
		@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(@outcome,@subgroup)
	end
  end

  
  # update the is_calculted and footnote fields, determine the footnote number, and 
  # update the table accordingly
  def assign_data_point_attributes
  	@field_id = params[:field_id]
  	@outcome_id = params[:outcome_id]
  	outcome = Outcome.find(@outcome_id)
  	@selected_timepoints = params[:selected_timepoints]
  	datapoint_id = params[:datapoint_id]
  	datapoint_type = params[:datapoint_type]   # either outcome or comparison
  	is_calculated = params[:is_calculated]
  	footnote = params[:footnote]
  	unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
  	@datapoint,@footnote_removed = OutcomeDataEntry.assign_data_point_attributes(datapoint_id, datapoint_type, is_calculated, footnote, @outcome_id, @subgroup.id)
  	
  	@footnotes = outcome.get_foot_notes(@subgroup.id)
  	
  end
  
  
  # given old and new footnote order values, update all footnotes accordingly.
  # this includes footnotes attached to both outcome results and comparison results
  def update_footnote_order
    @original_value = params[:original_value].to_i
    @new_value = params[:new_value].to_i
    @outcome_id = params[:outcome_id]
    @outcome = Outcome.find(@outcome_id)
    @selected_timepoints = params[:selected_timepoints]
    subgroup_id = params[:subgroup_id]
    unless subgroup_id == 0 || subgroup_id.nil?
    	@subgroup = OutcomeSubgroup.find(subgroup_id)
    else
    	@subgroup = nil
    end
    OutcomeDataEntry.update_footnote_numbers(@original_value,@new_value,@outcome,subgroup_id)
    @outcome = Outcome.find(@outcome_id)
  	@footnotes = @outcome.get_foot_notes(subgroup_id)
  	
  	unless ExtractionForm.is_diagnostic?(@outcome.extraction_form_id)
	  	# update the existing results session
	  	existing_results = session[:existing_results]
	  	key = "#{@outcome.title}_#{@outcome.id}_#{@subgroup.title}_#{@subgroup.id}"
	  	existing_results[key] = @outcome.get_existing_results(@subgroup.id)
	  	session[:existing_results] = existing_results

	  	#-----------------------------------------
		# update the existing comparisons table
		#-----------------------------------------
		existing_comparisons = session[:existing_comparisons]
		ocdes = OutcomeDataEntry.where(:subgroup_id=>@subgroup.id, :outcome_id=>@outcome.id)
		this_comparison = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
		key = "#{@outcome.id}_#{@subgroup.id}"
		existing_comparisons[:between][key] = this_comparison[:between][key]	
		existing_comparisons[:within][key] = this_comparison[:within][key]	
		session[:existing_comparisons] = existing_comparisons
	end
  end
	#-------------------------------------------------------------
	# ALL CODE BELOW THIS POINT IS RELATED TO BETWEEN ARM COMPARISONS
	#-------------------------------------------------------------

	
  # Display the table to allow users to enter comparisons between arms
  def create_between_arm_table
  	@selected_timepoints = params[:selected_timepoints]
  	@selected_tp_array = @selected_timepoints.split("_")
  	subgroup_id = params[:subgroup_id].nil? ? 0 : params[:subgroup_id]
  	@subgroup = subgroup_id == 0 ? nil : OutcomeSubgroup.find(subgroup_id)
  	@outcome_id = params[:outcome_id]
  	@comparisons = OutcomeDataEntry.create_comparisons("between",@selected_tp_array,@outcome_id,subgroup_id)
  	@outcome = Outcome.find(@outcome_id)
  	@project_id = params[:project_id]
		
  	#-----------------------------------------
  	# Data for the entry table
  	#-----------------------------------------
  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)
		
	
	  render "/outcome_data_entries/show_entry_table"
  end
  #-----------------------------------------
  # UPDATE MEASURES ASSOCIATED WITH A COMPARISON
  #-----------------------------------------
	def show_comparison_measures_form
	  @timepoint_id = params[:timepoint_id]
	  @selected_timepoints = params[:selected_timepoints]
	  @extraction_form_id = params[:extraction_form_id]
	  @study_id = params[:study_id]
	  @project_id = params[:project_id]
	  @comparison_id = params[:comparison_id]
	  outcome_type = params[:outcome_type]
	  @subgroup_id = params[:subgroup_id] == "" ? 0 : params[:subgroup_id]

	  # section number specific to diagnostic test entries
	  section_num = params[:dx_section]

	  # get a list of all measures
	  ocType = section_num.nil? ? outcome_type.downcase : "diagnostic_#{section_num}"
	  ocType = ocType == "time to event" ? "survival" : ocType
	  if @project_id == 427 || @project_id == 553
	  	@all_measures = DefaultCevgMeasure.where(:outcome_type=>ocType,:results_type=>1)
	  else
	  	@all_measures = DefaultComparisonMeasure.where(:outcome_type=>ocType,:within_or_between=>1)
	  end
	  
	  # get the measures for this particular comparison
	  @selected_measures = ComparisonMeasure.where(:comparison_id=>@comparison_id)
	  comparison = Comparison.find(@comparison_id)
	  unless comparison.nil?
		  @all_user_defined_measures = comparison.get_all_user_defined_measures
		else
			@all_user_defined_measures = []
		end
	  
	  unless section_num.nil?	
	  	@show_measures_for = case section_num.to_i
		  	when 1
		  		'Diagnostic Test Descriptive Result Measures'
		  	when 2
		  		'Diagnostic Test Measures Assuming a Reference Standard'
		  	else
		  		'Diagnostic Test Measures for Additional Analysis'
		  	end
		
	  else	
	  	@show_measures_for = "Between-Arm Comparison"
	  end
	  render '/outcome_data_entries/show_measures_form'
	end
	
	# update the measures associated with between arm comparisons
	def update_comparison_measures
		apply_to = params[:changes_apply_to]
		previously_saved = params[:previously_checked].nil? ? [] : params[:previously_checked]
		previously_user_defined = params[:previously_defined_checked].nil? ? [] : params[:previously_defined_checked]
		measures = params[:measures].nil? ? [] : params[:measures]
		user_defined_measures = params[:user_defined_measures].nil? ? [] : params[:user_defined_measures]
		new_measure_titles = params[:user_defined_titles]
		new_measure_descriptions = params[:user_defined_descriptions]
	    comparison_id = params[:comparison_id]
	    comparison = Comparison.find(comparison_id)
    	if apply_to == "this"
    		Comparison.update_measures(measures, comparison_id, previously_saved)
			Comparison.update_measures(user_defined_measures, comparison_id, previously_user_defined,'user-defined')
			unless (new_measure_titles.nil?)
				Comparison.create_new_measures(new_measure_titles, new_measure_descriptions, [comparison_id], comparison.within_or_between)
			end
		elsif apply_to == "all"
			Comparison.update_measures_for_all(measures, comparison.outcome_id, comparison.extraction_form_id, comparison.study_id,comparison.within_or_between,comparison.subgroup_id,'default',comparison.section)
			Comparison.update_measures_for_all(user_defined_measures, comparison.outcome_id, comparison.extraction_form_id, comparison.study_id,comparison.within_or_between,comparison.subgroup_id,'user-defined',comparison.section)
			unless (new_measure_titles.nil?)
				comparison_ids = Comparison.where(:within_or_between=>comparison.within_or_between, :study_id=>comparison.study_id,
												  :extraction_form_id=>comparison.extraction_form_id, :outcome_id=>comparison.outcome_id).select("id")
				comparison_ids = comparison_ids.collect{|x| x.id}
				Comparison.create_new_measures(new_measure_titles, new_measure_descriptions, comparison_ids, comparison.within_or_between)
			end
		end
		@selected_timepoints = params[:selected_timepoints]
		@selected_tp_array = @selected_timepoints.split("_")
	  	@outcome_id = comparison.outcome_id
	  	@outcome = Outcome.find(@outcome_id)
	    @subgroup = params[:subgroup_id] == 0 ? nil : OutcomeSubgroup.find(params[:subgroup_id])
	  	#-----------------------------------------
	  	# Data for the entry table
	  	#-----------------------------------------
	  	@is_diagnostic = ExtractionForm.is_diagnostic?(comparison.extraction_form_id)
	  	@checkbox_timepoints = @outcome.outcome_timepoints
	  	# If this extraction form deals with RCT data...
		if !@is_diagnostic
	  		@selected_timepoints = OutcomeDataEntry.get_selected_timepoints(@outcome,@subgroup)

	  		@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
			@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
			@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
			@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

		# Otherwise, gather the diagnostic test comparison data.
		else
			@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(@outcome,@subgroup)

			@outcome_id, @study_id, @extraction_form_id, @selected_tp_array, @timepoints, 
			@comparisons, @comparators, @all_comparators, @comparison_measures, @comparison_datapoints, @index_tests, 
			@reference_tests, @thresholds, @footnotes = OutcomeDataEntry.get_diagnostic_test_results(@outcome,@subgroup,@selected_timepoints)

			@index_test_options, @reference_test_options = DiagnosticTest.get_select_options(@index_tests,@reference_tests,@thresholds)
		end
			ef = ExtractionForm.find(@extraction_form_id)
			@project_id = ef.project_id
	  	render "outcome_data_entries/update_measures"
	end
	
	# clear_comparison_data
	# clear all BETWEEN ARM comparison data for a given outcome, timepoint, comparison type, etc.
	def clear_comparisons
		@selected_timepoints = params[:selected_timepoints]
		@selected_tp_array = @selected_timepoints.split("_")
		@outcome_id = params[:outcome_id]
		@subgroup_id = params[:subgroup_id]
		@study_id = params[:study_id]
		@extraction_form_id = params[:extraction_form_id]
		comparison_type = params[:comparison_type]
		@outcome = Outcome.find(@outcome_id)
		@is_diagnostic = ExtractionForm.is_diagnostic?(@extraction_form_id)
		if OutcomeDataEntry.remove_comparison_data(comparison_type, @outcome_id, @subgroup_id, @study_id, @extraction_form_id)
		  #flash[:notice] = "Comparisons were successfully deleted."
		else
			
		end
		
		unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
		
		@checkbox_timepoints = @outcome.outcome_timepoints
		
		# If this extraction form deals with RCT data...
		if !@is_diagnostic
	  		@selected_timepoints = OutcomeDataEntry.get_selected_timepoints(@outcome,@subgroup)

	  		@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
			@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
			@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
			@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

		# Otherwise, gather the diagnostic test comparison data.
		else
			all_tps = @outcome.outcome_timepoints.collect{|x| x.id.to_s}.join("_")
			@selected_timepoints = {1=>all_tps, 2=>all_tps, 3=>all_tps}

			@outcome_id, @study_id, @extraction_form_id, @selected_tp_array, @timepoints, @comparisons, 
			@comparators, @all_comparators, @comparison_measures, @comparison_datapoints, @index_tests, 
			@reference_tests, @thresholds, @footnotes = OutcomeDataEntry.get_diagnostic_test_results(@outcome,@subgroup,@selected_timepoints)

			@index_test_options, @reference_test_options = DiagnosticTest.get_select_options(@index_tests,@reference_tests,@thresholds)
		end
		#----------------
			ef = ExtractionForm.find(@extraction_form_id)
			@project_id = ef.project_id 
	  	render "/outcome_data_entries/show_timepoints"
	end

	# re-order the rows in the results table. To do this, find all OCDEs assigned to the outcome,
	# study, extraction form combination and then reorder them based on the newly changed row number
	def order_results_rows
		ocde_id = params[:ocde_id]
		ocde = OutcomeDataEntry.find(ocde_id)
		outcome_id = params[:outcome_id]
		@outcome = Outcome.find(outcome_id)
		@selected_timepoints = params[:selected_timepoints]
		new_pos = params[:new_position].to_i
		ocde.update_display_number(new_pos)
		
		unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
		#-----------------------------------------
	  	# Data for the entry table
	  	#-----------------------------------------
	  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)
  	ef = ExtractionForm.find(@extraction_form_id)
		@project_id = ef.project_id 
		render '/outcome_data_entries/show_entry_table'
	end
	
	#-------------------------------------------------------------
  # ALL CODE BELOW THIS POINT IS RELATED TO WITHIN ARM COMPARISONS
  #-------------------------------------------------------------
  
  
  # Display the table to allow users to enter comparisons between arms
  def create_within_arm_table
  	@selected_timepoints = params[:selected_timepoints]
  	@selected_tp_array = @selected_timepoints.split("_")
  	@outcome_id = params[:outcome_id]
  	subgroup_id = params[:subgroup_id].nil? ? 0 : params[:subgroup_id]
  	@subgroup = subgroup_id == 0 ? nil : OutcomeSubgroup.find(subgroup_id)
  	# comparisons within-arm are created on a row-by-row basis, using the row number as the group_id
  	OutcomeDataEntry.create_comparisons("within",[1],@outcome_id,subgroup_id)
  	@outcome = Outcome.find(@outcome_id)
  	@project_id = params[:project_id]
  	unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
  	#-----------------------------------------
  	# Data for the entry table
  	#-----------------------------------------
  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

		render "/outcome_data_entries/show_entry_table"
	end


  #--------------------------------------
  # add_within_arm_comparison_row
  # add another arm to the within-arm comparison table. This will also
  # update the 'previously entered' table.
  #--------------------------------------
	def add_within_arm_comparison_row
	  # gather up the information sent via ajax
		@outcome_id = params[:outcome_id]
		@outcome_type = params[:outcome_type]
		@subgroup_id = params[:subgroup_id].nil? ? 0 : params[:subgroup_id]
	  study_id = params[:study_id]
	  ef_id = params[:ef_id]
	  @comparator_id = params[:comparator_id]
	  row_num = params[:group_id]
	  @selected_timepoints = params[:selected_timepoints]
	  @selected_tp_array = @selected_timepoints.split("_")
	  @timepoints = OutcomeTimepoint.find(@selected_tp_array)
	  @comparison = Comparison.create(:within_or_between=>"within",:study_id=>study_id,:extraction_form_id=>ef_id,
	  							:outcome_id=>@outcome_id, :subgroup_id=>@subgroup_id, :group_id=>row_num)
	  @comparison.assign_measures
	  @comparison_id = @comparison.id
	  @wa_measures = OutcomeDataEntry.get_within_arm_measures([@comparison])
	  @arms = Study.get_arms(study_id)
	  @project_id = params[:project_id]
	  render 'outcome_data_entries/wa_comparisons/add_within_arm_comparison_row.js.erb'
	end
	def remove_within_arm_comparison_row
		@outcome_id = params[:outcome_id]
		@outcome = Outcome.find(@outcome_id)
		@study_id = @outcome.study_id
		@extraction_form_id = @outcome.extraction_form_id
		wac_id = params[:wac_id]
		@project_id = params[:project_id]
		Comparison.destroy(wac_id)
		@selected_timepoints = params[:selected_timepoints]
		
		unless params[:subgroup_id].nil?
			@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
		else
			@subgroup = nil
		end
		#-----------------------------------------
  	# Data for the entry table
  	#-----------------------------------------
  	@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
		@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
		@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
		@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)

		render "/outcome_data_entries/show_entry_table"
	end
	# update measures associated with a comparison
	def show_within_arm_comparison_measures_form
	  @selected_timepoints = params[:selected_timepoints]
	  @comparison_id = params[:comparison_id]
	  @outcome_type = params[:outcome_type]
	  @outcome_id = params[:outcome_id]
	  @subgroup_id = params[:subgroup_id]
	  @project_id = params[:project_id]
	  # get a list of all measures
	  @all_measures = DefaultComparisonMeasure.where(:outcome_type=>@outcome_type.downcase,:within_or_between=>0)
	  # get the measures for this particular comparison
	  @selected_measures = ComparisonMeasure.where(:comparison_id=>@comparison_id)
	  
	  comparison = Comparison.find(@comparison_id)
	  unless comparison.nil?
		  @all_user_defined_measures = comparison.get_all_user_defined_measures
		else
			@all_user_defined_measures = []
		end

		@show_measures_for = "Within-Arm Comparison"
	  render '/outcome_data_entries/show_measures_form'
	end

	# refresh_existing_results_table
	# to cut down on query times, we do not automatically update the existing results table. However, the user
	# may choose to update it by clicking a link. 
	def refresh_existing_results
		@study = Study.find(params[:study_id])
		@extraction_form_id = params[:extraction_form_id]
		
		@is_diagnostic = ExtractionForm.is_diagnostic?(@extraction_form_id)	
		
		unless @is_diagnostic
			@existing_results = @study.get_existing_results_for_session(@extraction_form_id)
			ocdes = @study.get_data_entries
			@existing_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
			session[:study_arms] = Arm.find(:all, :conditions=>["study_id = ? AND extraction_form_id=?",@study.id, @extraction_form_id], :order=>"display_number ASC", :select=>["id","title","description","display_number","extraction_form_id","note","default_num_enrolled","is_intention_to_treat"])
		else
			comparisons = @study.get_comparison_entries
			session[:study_arms] = nil
			@existing_comparisons, @existing_comparators = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)
			# GET THE SUBGROUPS ASSOCIATED WITH THESE OUTCOMES
			@outcomes = Outcome.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",@study.id,@extraction_form_id],:select=>["id","title","units","description","extraction_form_id"])
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
			@subgroups = @outcome_subgroups.to_json
		end
	end
end