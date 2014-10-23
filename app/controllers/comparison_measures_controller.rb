class ComparisonMeasuresController < ApplicationController

	def create
		@comparison_measure = ComparisonMeasure.new(params[:comparison_measure])
		
		if @comparison_measure.save
			@comparison = Comparison.find(@comparison_measure.comparison_id)
			@comparison_measures = ComparisonMeasure.where(:comparison_id=>@comparison.id)
			@comparison_data_points = ComparisonMeasure.get_data_points(@comparison_measures.collect{|x| x.id})
			@comparison_data_point = ComparisonDataPoint.new
			@comparison_measure = ComparisonMeasure.new
			@study = Study.find(@comparison.study_id)
			@outcome = Outcome.find(@comparison.outcome_id)
			@extraction_form = ExtractionForm.find(@comparison.extraction_form_id)
			@td_id = "#" + @comparison.comparators.to_s
			@type = @comparison.within_or_between
			@previous_measures = ComparisonMeasure.get_previous_measures(@comparison.study_id)
			
			@entry_partial = "comparison_measures/form"
			@entry_container = "measure_form_div"
			@table_container2 = "measure_display_div" 
			@table_partial2 = "comparison_measures/measure_list"
			@table_container = "form_div"
			object_ids = @comparison.comparators.split("_")
			
			if @type == "between"
			@table_partial = "comparison_data_points/between_arm_comparisons"
				@arms = []
				object_ids.length.times do |i|
					tmp = Arm.find(object_ids[i])
					@arms[i] = tmp
				end
			else
				@table_partial = "comparison_data_points/within_arm_comparisons"
				@timepoints = []
				object_ids.length.times do |i|
					tmp = OutcomeTimepoint.find(object_ids[i])
					@timepoints[i] = tmp
				end
			end
		else
			problem_html = create_error_message_html(@comparison_measure.errors)
			flash[:modal_error] = problem_html
			@error_partial = "layouts/modal_info_messages"
		end
		#render "shared/saved.js.erb"	THIS ONE RENDERS create.js.erb
	end
	
	def import_measures
		comparison_id = params[:comparison_id]
		
		# set up the comparison measures for this comparison
		titles = params[:titles]
		units = params[:units]
		descriptions = params[:descriptions]
		
		# find out which ones the user actually selected
		chosen = params[:chosen]
		
		chosen.keys.each do |key|
			index = chosen[key]
			tmp = ComparisonMeasure.create(:title=>titles[index.to_s], :description=>descriptions[index.to_s], :unit=>units[index.to_s], :comparison_id=>comparison_id)
		end
				
		@comparison = Comparison.find(comparison_id)
		@comparison_measures = ComparisonMeasure.where(:comparison_id=>@comparison.id)
		@comparison_data_points = ComparisonMeasure.get_data_points(@comparison_measures.collect{|x| x.id})
		@comparison_data_point = ComparisonDataPoint.new
		@comparison_measure = ComparisonMeasure.new
		@study = Study.find(@comparison.study_id)
		@outcome = Outcome.find(@comparison.outcome_id)
		@extraction_form = ExtractionForm.find(@comparison.extraction_form_id)
		@td_id = "#" + @comparison.comparators.to_s
		@type = @comparison.within_or_between
		@previous_measures = ComparisonMeasure.get_previous_measures(@comparison.study_id)
		
		@table_container = "form_div"
		
		object_ids = @comparison.comparators.split("_")
		
		if @type == "between"
			@table_partial = "comparison_data_points/between_arm_comparisons"
			@arms = []
			object_ids.length.times do |i|
				tmp = Arm.find(object_ids[i])
				@arms[i] = tmp
			end
		else
			@table_partial = "comparison_data_points/within_arm_comparisons"
			@timepoints = []
			object_ids.length.times do |i|
				tmp = OutcomeTimepoint.find(object_ids[i])
				@timepoints[i] = tmp
			end
		end
		#*************************************************************************		
		# NOTE THAT THIS FUNCTION RENDERS IMPORT_MEASURE.JS.ERB, NOT SAVED.JS.ERB
		#*************************************************************************
	end
	
	# edit an existing measure
	def edit
		@comparison_measure = ComparisonMeasure.find(params[:measure_id])
		@comparison = Comparison.find(@comparison_measure.comparison_id)
		@editing = true
		# render comparison_measures/edit.js.erb to view the update table		
	end
	
	# update an existing measure
	def update
		@comparison_measure = ComparisonMeasure.find(params[:id])
		if @comparison_measure.update_attributes(params[:comparison_measure]);
			@comparison = Comparison.find(@comparison_measure.comparison_id)
			@comparison_measures = ComparisonMeasure.where(:comparison_id=>@comparison.id)
			@comparison_data_points = ComparisonMeasure.get_data_points(@comparison_measures.collect{|x| x.id})
			@comparison_data_point = ComparisonDataPoint.new
			@comparison_measure = ComparisonMeasure.new
			@study = Study.find(@comparison.study_id)
			@outcome = Outcome.find(@comparison.outcome_id)
			@extraction_form = ExtractionForm.find(@comparison.extraction_form_id)
			@td_id = "#" + @comparison.comparators.to_s
			@type = @comparison.within_or_between
			@previous_measures = ComparisonMeasure.get_previous_measures(@comparison.study_id)
			@close_window = "measure_form_div"
			@entry_container = "measure_form_div"
			@entry_partial = "comparison_measures/form"
			@table_container = "measure_display_div"
			@table_partial = "comparison_measures/measure_list"
			@table_container2 = "form_div"
			object_ids = @comparison.comparators.split("_")
			if @type == "between"
				@table_partial2 = "comparison_data_points/between_arm_comparisons"
				@arms = []
				object_ids.length.times do |i|
					tmp = Arm.find(object_ids[i])
				  @arms[i] = tmp
				end
			else # if the type is 'within'...
				@table_partial2 = "comparison_data_points/within_arm_comparisons"
				@timepoints = []
				object_ids.length.times do |i|
					tmp = OutcomeTimepoint.find(object_ids[i])
				  @timepoints[i] = tmp
				end
			end
			render 'shared/saved.js.erb'
		else # if the update is unsuccessful...
			
		end
	end # end update
	
	# remove a comparison measure
	def destroy
		@comparison_measure = ComparisonMeasure.find(params[:id]);
		
		# find and delete any associated data points
		dataPoints = ComparisonDataPoint.where(:comparison_measure_id=>@comparison_measure.id)
		
		unless dataPoints.empty?
			dataPoints.each do |dp|
				dp.destroy	
			end
		end
		
		# get the comparison object that this measure belongs to
		@comparison = Comparison.find(@comparison_measure.comparison_id)
		
		# remove the comparison measure
		@comparison_measure.destroy
		
		# update the display tables and give a message that it was deleted successfully
		@comparison_measure = ComparisonMeasure.new
		@comparison_measures = ComparisonMeasure.where(:comparison_id=>@comparison.id)
		@comparison_data_points = ComparisonMeasure.get_data_points(@comparison_measures.collect{|x| x.id})
		@comparison_data_point = ComparisonDataPoint.new
		@comparison_measure = ComparisonMeasure.new
		@study = Study.find(@comparison.study_id)
		@outcome = Outcome.find(@comparison.outcome_id)
		@extraction_form = ExtractionForm.find(@comparison.extraction_form_id)
		@td_id = "#" + @comparison.comparators.to_s
		@type = @comparison.within_or_between
		@previous_measures = ComparisonMeasure.get_previous_measures(@comparison.study_id)
		@entry_container = "measure_form_div"
		@entry_partial = "comparison_measures/form"
		@editing=false
		
		@table_container = "measure_display_div"
		@table_partial = "comparison_measures/measure_list"
		
		@table_container2 = "form_div"
		object_ids = @comparison.comparators.split("_")
		if @type == "between"
			@table_partial2 = "comparison_data_points/between_arm_comparisons"
			@arms = []
			object_ids.length.times do |i|
				tmp = Arm.find(object_ids[i])
				@arms[i] = tmp
			end
		else
			@table_partial2 = "comparison_data_points/within_arm_comparisons"
			@timepoints = []	
			object_ids.length.times do |i|
				tmp = OutcomeTimepoint.find(object_ids[i])
				@timepoints[i] = tmp
			end		
		end
		render "shared/saved"
	end
	
	# refresh the entry partial for comparison measure creation when the user hits the cancel button
	def cancel_edit
		@comparison = Comparison.find(params[:comparison_id])
		@comparison_measure = ComparisonMeasure.new
		@entry_container = "measure_form_div"
		@entry_partial = "comparison_measures/form"
		@editing=false
		render "shared/saved"		
	end	
end
