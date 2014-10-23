class OutcomeDataPointsController < ApplicationController
  layout :determined_by_request
  
  def create
	  	@is_diagnostic = params[:diagnostic].nil? ? false : true
	  	datapoints = params[:datapoints]
	  	@outcome = Outcome.find(params[:outcome_id])
	  	@subgroup = OutcomeSubgroup.find(params[:subgroup_id])
	  	@selected_timepoints = params[:selected_timepoints]

	  	# there will be no datapoints saved for diagnostic test data
	  	OutcomeDataPoint.save_data(datapoints) unless datapoints.nil?
	  	between_arm_datapoints = params[:comparison_datapoints] # indexed by comparison ID
	  	between_arm_comparators = params[:comparator]           # indexed by column number
	  	between_arm_comparison_measures = params[:comparison_measures]  # indexed by comparison_id
	  	wac_datapoints = params[:wac_datapoints]
	  	wac_comparators = params[:wac_comparators]
	    
	    # SAVE BETWEEN-ARM COMPARISON DATA
	    two_by_two_data = params[:table2x2_datapoints]
	  	unless ((between_arm_datapoints.nil? || between_arm_comparators.nil? || between_arm_comparison_measures.nil?) && two_by_two_data.nil?)
	  		puts "-----------\n\nEntered between-arm comparison data\n\n"
	  		@updated_bac_comparator_ids, requires_table_update = Comparison.save_comparison_data(between_arm_comparators,between_arm_datapoints,between_arm_comparison_measures,@outcome.id,@subgroup.id, two_by_two_data)     
	  		@updated_bac_comparator_ids = @updated_bac_comparator_ids.to_json
	  	else
	  		puts "Something to do with between arms is nil!\n\n"
	  		puts "datapoints nil?: #{between_arm_datapoints.nil?}\n"
	  		puts "comparators nil?: #{between_arm_comparators.nil?}\n"
	  		puts "measures nil?: #{between_arm_comparison_measures.nil?}\n"
	  	end
	  	# SAVE WITHIN-ARM COMPARISON DATA
	  	unless (wac_datapoints.nil? || wac_comparators.nil?)
	      Comparison.save_within_arm_comparison_data(wac_datapoints, wac_comparators)
		end
		
		unless @is_diagnostic
			# update the existing results session
		  	#existing_results = session[:existing_results]
		  	#key = "#{@outcome.title}_#{@outcome.id}_#{@subgroup.title}_#{@subgroup.id}"
		  	#existing_results[key] = @outcome.get_existing_results(@subgroup.id)
		  	#session[:existing_results] = existing_results

		  	# update the existing comparisons session
		  	#ocdes = OutcomeDataEntry.where(:outcome_id=>@outcome.id, :subgroup_id=>@subgroup.id)
		  	#existing_comparisons = session[:existing_comparisons]
			#this_comparison = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
			#key = "#{@outcome.id}_#{@subgroup.id}"
			#existing_comparisons[:between][key] = this_comparison[:between][key]	
			#existing_comparisons[:within][key] = this_comparison[:within][key]	
			#session[:existing_comparisons] = existing_comparisons
		else
			#session[:existing_results] = []
			#session[:existing_comparisons] = []
			@study = Study.find(@outcome.study_id)
			#comparisons = @study.get_comparison_entries
			session[:study_arms] = nil
			#session[:existing_comparisons], session[:existing_comparators] = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)
			@outcomes = Outcome.find(:all, :conditions=>["study_id=?",@study.id],:select=>["id","title","extraction_form_id"])
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
		end
	  	
	  	if requires_table_update
	  		@checkbox_timepoints = @outcome.outcome_timepoints
	  		@outcome_id, @study_id,@extraction_form_id, @selected_tp_array, @timepoints, @OCDEs, 
				@measures, @datapoints, @arms, @comparisons, @comparison_measures, @comparators, 
				@all_comparators, @num_comparators, @comparison_datapoints, @wa_comparisons, @wa_measures, 
				@wa_comparators, @wa_all_comparators, @wa_datapoints, @footnotes = OutcomeDataEntry.get_information_for_entry_table(@outcome,@subgroup,@selected_timepoints)
				render "outcome_data_entries/show_timepoints"
	  	else
	  		# indicate to the view that we'll update this div
=begin
		  	unless @is_diagnostic
			  	@table_container = 'existing_results_div'
			  	@table_partial = 'outcome_data_entries/existing_results'
			else
				@table_container = 'existing_results_div'
				@table_partial = 'outcome_data_entries/existing_diagnostic_results'
			end
		  	@message_div = "saved_item_indicator"
	  		render "shared/saved"
=end
	  	end
		@msg_type = "success"
		@msg_title = "Success!"
		@msg_description = "Your results have been saved."
		render "shared/render_partial.js.erb"

  	end
  
	def modify_timepoints_display
		@outcome = Outcome.find(params[:outcome][:id])
		@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
		@study = Study.find(@outcome.study_id)
		@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
		@project = Project.find(@extraction_form.project_id)	
		timepoints_list = Array.new
		params[:outcome][:outcome_timepoints_attributes].each do |timepoint_hash|	
			timepoint_num = timepoint_hash[1]["number"]
			timepoint_unit = timepoint_hash[1]["time_unit"]
			if timepoint_hash[1].has_key?("id") && (timepoint_hash[1]["_destroy"] == "false")
				timepoint_id = timepoint_hash[1]["id"]
				timepoints_list << timepoint_id.to_i
				@old_tp = OutcomeTimepoint.find(timepoint_id)
				@old_tp.number = timepoint_num				
				@old_tp.time_unit = timepoint_unit
				@old_tp.save		
			else
				if (timepoint_hash[1]["_destroy"] == "false")
					@new_tp = OutcomeTimepoint.new
					@new_tp.outcome_id = @outcome.id
					@new_tp.number = timepoint_num
					@new_tp.time_unit = timepoint_unit
					@new_tp.save
					timepoints_list << @new_tp.id
				end
			end
		end
		@outcome_timepoints.each do |one_tp|
			if timepoints_list.include?(one_tp.id)
			else
				one_tp.destroy
			end
		end
		include_index = 0
		included_timepoints_list = []
		params.each do |param|
			if param[0].starts_with?("include")
				include_val = param[1]
				selected_tp = timepoints_list[include_index]
				if include_val == "yes"
					included_timepoints_list << selected_tp.to_i
				end
				include_index = include_index + 1
			end
		end
		@outcome_timepoints = OutcomeTimepoint.find_all_by_id(included_timepoints_list)
		@arms = Arm.where(:study_id => @outcome.study_id, :extraction_form_id => @outcome.extraction_form_id).all
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@outcome_measure = OutcomeMeasure.new
		@outcome_data_point = OutcomeDataPoint.new
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@time_units = Outcome.get_timepoint_unit_options(@study.id)
		unless @study_extforms.empty?
			@extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
		end		
	end
	
	def saved_results
	end
	
  def setup_timepoints
	@study = Study.find(params[:study_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@outcome = Outcome.find(params[:outcome_id])
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
	@arms = Arm.where(:study_id => @outcome.study_id, :extraction_form_id => @outcome.extraction_form_id).all 
  end

  def setup_arms
	@study = Study.find(params[:study_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@outcome = Outcome.find(params[:outcome_id])
	@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
  end
  
  def show_table
	@study = Study.find(params[:study_id])
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@project = Project.find(@extraction_form.project_id)
	@outcome = Outcome.find(params[:timepoint][:outcome_id])
	# get timepoints from paramters
	@tp_ids_list = []
	if !params[:timepoint][:selected_ids].nil?
		params[:timepoint][:selected_ids].each do |id|
			@tp_ids_list << id.to_i
		end
	end
	@outcome_timepoints = OutcomeTimepoint.find_all_by_id(@tp_ids_list)
	@arms = Arm.where(:study_id => @outcome.study_id, :extraction_form_id => @outcome.extraction_form_id).all
	@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
	@outcome_measure = OutcomeMeasure.new
	@outcome_data_point = OutcomeDataPoint.new
	@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
	@time_units = Outcome.get_timepoint_unit_options(@study.id)
    unless @study_extforms.empty?
    	@extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
	end	
  end

	# if the user presses the cancel button when editing a result, close the form and delete the result.
	def cancel_results_creation
		@outcome = Outcome.find(params[:outcome_id])
		@arms = Arm.find_all_by_id(params[:selected_arms])
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		#@project = Project.find(params[:project_id])
		#@study = Study.find(params[:study_id])
		@outcome_timepoints = OutcomeTimepoint.find_all_by_id(params[:selected_timepoints])
	
		measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		datapoints = []
		unless measures.empty?
			measures.each do |measure|
				@arms.each do |one_arm|
					@outcome_timepoints.each do |one_tp|
						datapoint = OutcomeDataPoint.where(:outcome_measure_id => measure.id, :extraction_form_id => @extraction_form.id, :arm_id => one_arm.id, :timepoint_id => one_tp.id)
						unless datapoint.empty?
							datapoints << datapoint.first
						end
					end
				end
			end
		end

		# remove any data points associated with the comparison
		unless datapoints.empty?
			datapoints.each do |dp|		
				dp.destroy
			end
		end	
		
		# remove any measures associated with the comparison
		unless measures.empty?
			measures.each do |m|
				m.destroy
			end
		end
	end
	  
	def edit_results_table
		@outcome = Outcome.find(params[:outcome_id])
		@study = Study.find(@outcome.study_id)
		@outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
		@outcome_measures = OutcomeMeasure.where(:outcome_id => @outcome.id).all
		@arms = Arm.where(:study_id => @study.id).all
		@outcome_measure = OutcomeMeasure.new
		@extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
		@outcome_data_point = OutcomeDataPoint.new
	end
  
  
 protected
 def determined_by_request
   if request.xhr?
     return false
   else
     'application'
   end
 end
  
  
end
