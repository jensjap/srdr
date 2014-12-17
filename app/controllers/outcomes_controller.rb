class OutcomesController < ApplicationController
  before_filter :require_user
  layout "two_column_layout"
  # new
  # create a new outcome
  def new
    begin 
    @editing = false
    @has_data = false
    @outcome = Outcome.new
    @outcome_subgroups = []   
    @outcome_timepoints = []
    @study = Study.find(params[:study_id])
    @project = Project.find(params[:project_id])  
    @study_extforms = StudyExtractionForm.where(:study_id=>@study.id).all
    @extraction_form = ExtractionForm.find(params[:extraction_form_id])
    # determine if there's another outcome previously entered into this study, and if so, pull information from it
    @previous_outcome_study = Outcome.where(:study_id => @study.id).order("created_at DESC")
    if (@previous_outcome_study.length > 0)
      @prev_outcome = @previous_outcome_study[0]
      previous_outcome_subgroups = OutcomeSubgroup.where(:outcome_id=>@prev_outcome.id).select(["title","description"])

      # only pull in the previous subgroups if they created more than the default subgroup, which would mean only 1 in the list
      unless previous_outcome_subgroups.length < 2
        @previous_outcome_subgroups = previous_outcome_subgroups
      end
      
      @previous_outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @prev_outcome.id).select(["number","time_unit"])

    end

    # now get information related to outcomes specified in other studies that are in the same project. We can
    # use the following information to try and standardize input:
    # Outcome Title
    # Outcome Description
    # Outcome Type
    @outcome_options = Outcome.get_dropdown_options_for_new_outcome(params[:extraction_form_id], @study.id)
    #@outcome_options = Outcome.get_suggested_outcomes_for_ef(params[:extraction_form_id], @study.id)

    # get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
    # sections in each form, sections borrowed from other forms, key questions associated with 
    # each section, etc.
    #unless @study_extforms.empty?
    # @extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
    #end
    
    # Add in timepoint unit options
    #@time_units = Outcome.get_timepoint_unit_options(@study.id)
    
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
  end

    # edit
  # edit an existing outcome
  def edit
    @outcome = Outcome.find(params[:id])
    @outcome_subgroups = @outcome.outcome_subgroups
    @extraction_form = ExtractionForm.find(params[:extraction_form_id])
    @project = Project.find(@extraction_form.project_id)
    @study = Study.find(params[:study_id])  
    @study_arms = Arm.find(:all, :conditions => {:study_id => @study.id}) 
    @editing = true
    @outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
    @study_extforms = StudyExtractionForm.where(:study_id=>@study.id).all
    @has_data, data_locations = @outcome.has_data
    #@has_data = @outcome.has_data

    # get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
    # sections in each form, sections borrowed from other forms, key questions associated with 
    # each section, etc.
    #unless @study_extforms.empty?
    #        @extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
    #end
    @outcome_options = Outcome.get_suggested_outcomes_for_ef(params[:extraction_form_id], @study.id)
    # Add in timepoint unit options
    #@time_units = Outcome.get_timepoint_unit_options(@study.id)
 end

  # create
  # save a new outcome
  def create
    unless (params[:outcome][:title] == "Choose a suggested outcome...") || (params[:outcome][:title] == "") || params[:timepoint_numbers].values.include?("") || params[:subgroup_names].values.include?("")

    @outcome = Outcome.new(params[:outcome])
    @outcome.study_id = params[:outcome][:study_id]
    @outcome.extraction_form_id = params[:outcome][:extraction_form_id] 
    if @saved = @outcome.save
    
      # save timepoint definitions for the new outcome
      timepoint_numbers = params[:timepoint_numbers]
      timepoint_units = params[:timepoint_units]
      # put the timepoint numbers in the proper order by key
      puts "Timepoint numbers is #{timepoint_numbers} and units is #{timepoint_units}"
      if timepoint_numbers.keys.first == 0
        timepoint_numbers = timepoint_numbers.sort{|a,b| a[0].to_i <=> b[0].to_i}
      else
        timepoint_numbers = timepoint_numbers.sort{|a,b| b[0].to_i<=>a[0].to_i}
      end


      timepoint_numbers.each_with_index do |numArray, i|
        OutcomeTimepoint.create(:outcome_id=>@outcome.id, :number=>numArray[1],
                                :time_unit=>timepoint_units[numArray[0].to_s])
      end
      @outcome_timepoints = @outcome.outcome_timepoints

      # save subgroup definitions for the new outcome
      sg_names = params[:subgroup_names]
      sg_desc = params[:subgroup_descriptions]
      unless sg_names["0"].nil?
        OutcomeSubgroup.create(:outcome_id=>@outcome.id,:title=>"All Participants",:description=>"All articipants involved in the study (Default)")
        sg_names.delete("0")
      end
      sg_names.keys.each do |key|

        OutcomeSubgroup.create(:outcome_id=>@outcome.id, :title=>sg_names[key].strip,
                               :description=>sg_desc[key].strip)
      end
      @outcome_subgroups = @outcome.outcome_subgroups.order("id ASC")
    
  
      @study = Study.find(params[:outcome][:study_id])
      @project = Project.find(@study.project_id)
      @extraction_form = ExtractionForm.find(params[:outcome][:extraction_form_id])
      @study_extforms = StudyExtractionForm.where(:study_id=>@study.id)   
      # get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
      # sections in each form, sections borrowed from other forms, key questions associated with 
      # each section, etc.
      unless @study_extforms.empty?
        @extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
      end
      @outcomes = Outcome.find(:all, :conditions => {:study_id => @study.id, :extraction_form_id => @extraction_form.id})
      @outcome_subgroups_hash = Outcome.get_subgroups_by_outcome(@outcomes)
      @outcome_timepoints = OutcomeTimepoint.where(:outcome_id => @outcome.id).all
      @study_arms = Arm.find(:all, :conditions => {:study_id => @study.id}, :order => :display_number)    
      @outcome = Outcome.new
      @time_units = Outcome.get_timepoint_unit_options(@study.id)
    else
      problem_html = create_error_message_html(@outcome.errors)
      flash[:modal_error] = problem_html
    end
  else
    if params[:outcome][:title] == "Choose a suggested outcome..." || params[:outcome][:title].blank?
      flash[:modal_error] = "Please select an outcome title or create one by selecting \"Other\"."
    elsif params[:timepoint_numbers].values.include?("")
      flash[:modal_error] = "One of more of the timepoint definitions is blank. Please correct this and re-submit."
    elsif params[:subgroup_names].values.include?("")
        flash[:modal_error] = "One or more of the subgroup definitions is blank. Please correct this and re-submit."
    end
  end
end

    # update any changes to previously specified outcomes
=begin
    if !params[:outcome_timepoints_attributes].nil? 
      params[:outcome_timepoints_attributes].each do |item|
        @existing_id = item[1][:id]
        @outcome_tp = OutcomeTimepoint.find(@existing_id)
        @outcome_tp.number = item[1][:number]
        @outcome_tp.time_unit = item[1][:time_unit]
        @outcome_tp.outcome_id = @outcome.id
        @outcome_tp.save
      end
    end
  
    # create newly specified outcomes
    if !params[:new_outcome_timepoints_attributes].nil?
      params[:new_outcome_timepoints_attributes].each do |item|
        @outcome_tp = OutcomeTimepoint.new
        @outcome_tp.number = item[1][:number]
        @outcome_tp.time_unit = item[1][:time_unit]
        @outcome_tp.outcome_id = @outcome.id
        @outcome_tp.save  
      end 
    end
    
=end
      

    # update
  # update an existing outcome
  def update
    unless (params[:outcome][:title] == "Choose a suggested outcome...") || (params[:outcome][:title] == "") || params[:timepoint_numbers].values.include?("") || params[:subgroup_names].values.include?("")

      @outcome = Outcome.find(params[:id])
      @outcome.study_id = params[:outcome][:study_id]
      @outcome.extraction_form_id = params[:outcome][:extraction_form_id] 

      if @saved = @outcome.update_attributes(params[:outcome])
        # update the subgroup definitions
        @outcome.update_subgroups(params[:subgroup_names],params[:subgroup_descriptions])

        # udpate the timepoint definitions
        @outcome.update_timepoints(params[:timepoint_numbers],params[:timepoint_units])

        @study = Study.find(params[:outcome][:study_id])
        @extraction_form = ExtractionForm.find(params[:outcome][:extraction_form_id])
        @study_arms = Arm.where(:all, :conditions => {:study_id => params[:outcome][:study_id]}, :order => :display_number)
        @project = Project.find(@study.project_id)
        @outcomes = Outcome.where(:study_id => @study.id, :extraction_form_id => @extraction_form.id)
        @outcome_subgroups_hash = Outcome.get_subgroups_by_outcome(@outcomes)
        @study_extforms = StudyExtractionForm.where(:study_id => @study.id)
        
        # get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
        # sections in each form, sections borrowed from other forms, key questions associated with 
        # each section, etc.
        unless @study_extforms.empty?
          @extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
        end

        @outcome = Outcome.new
        @outcome_timepoints = Array.new
        @outcome_subgroups = Array.new
      else
        problem_html = create_error_message_html(@outcome.errors)
        flash[:modal_error] = problem_html
      end
    else
      if params[:outcome][:title] == "Choose a suggested outcome..." || params[:outcome][:title].blank?
        flash[:modal_error] = "Please select an outcome title or create one by selecting \"Other\"."
      elsif params[:timepoint_numbers].values.include?("")
        flash[:modal_error] = "One of more of the timepoint definitions is blank. Please correct this and re-submit."
      elsif params[:subgroup_names].values.include?("")
        flash[:modal_error] = "One or more of the subgroup definitions is blank. Please correct this and re-submit."
      end
    end
  end


    # destroy
  # destroy an existing outcome
  def destroy
    @outcome = Outcome.find(params[:id])
    @study = Study.find(@outcome.study_id)
    @project = Project.find(@study.project_id)
    @extraction_form = ExtractionForm.find(@outcome.extraction_form_id)
    @outcome_subgroups = Array.new
    @outcome_timepoints = Array.new

    # If results or comparisons has already been saved, don't allow 
    # outcome to be deleted
    has_data, data_locations = @outcome.has_data
    unless has_data
      @outcome.destroy 
      @outcomes = Outcome.find(:all, :conditions => {:study_id => @study.id, :extraction_form_id => @extraction_form.id})
      @outcome_subgroups_hash = Outcome.get_subgroups_by_outcome(@outcomes)
      @div_name = "outcomes_table"
      @partial_name = "outcomes/table"
      @msg_type = "success"
      @msg_title = "The Outcome was successfully deleted."  
      # get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
      # sections in each form, sections borrowed from other forms, key questions associated with 
      # each section, etc.
      render '/shared/render_partial.js.erb'
    else
        @msg_title = "#{@outcome.title} has associated data."
        @msg_description = "Data related to this outcome may be found in the following sections in this study: #{data_locations.join(", ")}. Please review and remove data associated with this outcome before continuing with deletion."
        @msg_type = "error"
        #flash[:error_message] = "You must remove all results and comparisons associated with this arm before it can be deleted"
        #@div_name = "info_messages"
        #@partial_name = "layouts/info_messages"
        render "shared/show_message.js.erb"
      #@outcomes = Outcome.find(:all, :conditions => {:study_id => @study.id, :extraction_form_id => @extraction_form.id})
      #flash[:error] = "You must remove all results, results measures and comparisons associated with this outcome before it can be deleted"
    end
  end
end
