class ComparisonsController < ApplicationController

	# destroy
	# Remove a comparison from entry table.
	# This function is typically called when outcome data entries are not present, which is
	# the case when entering diagnostic test data, for instance.
	def destroy
		comparison_id = params[:comparison_id]        # the comparison to destroy
		comparison = Comparison.find(comparison_id)   # the comparison object

		# get the outcome and subgroup associated with this comparison
		@outcome = Outcome.find(comparison.outcome_id)
		@subgroup = OutcomeSubgroup.find(comparison.subgroup_id)
		@is_diagnostic = true  # must set this in order for the show_timepoints view to render the correct info
		section = comparison.section

		#ocde.update_display_numbers_for_deletion unless(ocde.display_number.nil? || ocde.display_number == 0)

		# destroy the comparison
		comparison.destroy();

		# gather up table materials and reload the page.
		@checkbox_timepoints = @outcome.outcome_timepoints
		@selected_timepoints = Comparison.get_selected_timepoints_for_diagnostic_tests(@outcome,@subgroup)

		@outcome_id, @study_id, @extraction_form_id, @selected_tp_array, @timepoints, 
		@comparisons, @comparators, @all_comparators, @comparison_measures, @comparison_datapoints, @index_tests, 
		@reference_tests, @thresholds, @footnotes = OutcomeDataEntry.get_diagnostic_test_results(@outcome,@subgroup,@selected_timepoints)

		@index_test_options, @reference_test_options = DiagnosticTest.get_select_options(@index_tests,@reference_tests,@thresholds)

		session[:existing_results] = []
		session[:existing_comparisons] = []
		study = Study.find(@outcome.study_id)
		comparisons = study.get_comparison_entries
		session[:study_arms] = nil
		session[:existing_comparisons], session[:existing_comparators] = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)

		@outcomes = Outcome.find(:all, :conditions=>["study_id=?",@outcome.study_id],:select=>["id","title","extraction_form_id"])
		@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
		
	  	render 'outcome_data_entries/show_timepoints'
	end
end
	  	
=begin	  	#-----------------------------------------
	  	# Update the existing results table
	  	#-----------------------------------------
		existing = session[:existing_results]
		key = "#{@outcome.title}_#{@outcome.id}_#{@subgroup.title}_#{@subgroup.id}"
		entries = @outcome.get_existing_results(@subgroup.id)
		if entries.empty?
			existing.delete(key)
		else
			existing[key] = entries
		end
		session[:existing_results] = existing

		#-----------------------------------------
		# update the existing comparisons table
		#-----------------------------------------
		existing_comparisons = session[:existing_comparisons]
		this_comparison = OutcomeDataEntry.get_existing_comparisons_for_session(@OCDEs)
		key = "#{@outcome_id}_#{@subgroup.id}"
		existing_comparisons[:between][key] = this_comparison[:between][key]	
		existing_comparisons[:within][key] = this_comparison[:within][key]	
		session[:existing_comparisons] = existing_comparisons
    	render '/outcome_data_entries/show_timepoints'
=end

