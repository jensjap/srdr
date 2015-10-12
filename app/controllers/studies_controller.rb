# encoding: utf-8

# This controller handles all pages for study data extraction, as well as basic creation, updating and deletion of studies.
class StudiesController < ApplicationController

	respond_to :js, :html
	before_filter :require_user, :except => [:index, :show]
	before_filter :require_lead_role, :only=>[:batch_assignment, :simport]
	before_filter :require_editor_role, :except=>[:index, :show]
	before_filter :require_project_membership, :only => [:show]

	#layout "two_column_layout", :except=>[:new,:show]

    require 'assignment_job'
    #require 'study_record'
    #require 'question_list'
    require 'fileutils'
    require 'import_handler'
    require 'background_simport'

    def split
		begin
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			@data = QuestionBuilder.get_questions("design_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned})
			@data_point = DesignDetailDataPoint.new
			
			# Now get any additional user instructions for this section
	        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "DESIGN", "GENERAL"])
	        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

	        # Fetch document_html from DAA API
	        #!!! Stubbed for now. Needs to make actual call and fetch document.
			@document_id = "1"
	        response = HTTParty.get('http://api.daa-dev.com:3030/v1/documents/' + @document_id)
	        @document_html = response

			if @data[:by_arm] == true || @data[:by_outcome] == true
				render :action=>'question_based_section_by_category', :layout => false
			else
				render :action=>'question_based_section_split', :layout => "split_screen"
			end
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end

    end

	# show the print layout in order to export a study summary to pdf.
  	def index_pdf
		@study = Study.find(params[:study_id])
		@project = Project.find(@study.project_id)
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id).all	
		@study_qs = StudyKeyQuestion.where(:study_id => @study.id).all
		@study_questions = []
		@study_qs.each{|i| @study_questions << KeyQuestion.find(i.key_question_id)}
		@study_questions.sort! { |a,b| a.question_number <=> b.question_number }	
		@primary_publication = PrimaryPublication.where(:study_id => @study.id).first
		@secondary_publications = SecondaryPublication.where(:study_id => @study.id).all	
		@study_arms = Arm.where(:study_id => @study.id).all	
		@outcomes = Outcome.where(:study_id => @study.id).all
		@adverse_events = AdverseEvent.where(:study_id => @study.id).all
		@categorical_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Categorical").all
		@continuous_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Continuous").all		
		@outcomes = Outcome.where(:study_id => @study.id).all
		# get the study title, which is the same as the primary publication for the study
		@study_title = PrimaryPublication.where(:study_id => @study.id).first
		@study_title = @study_title.nil? ? "" : @study_title.title.to_s	
		@baseline_characteristic_custom_fields = BaselineCharacteristic.where(:study_id => @study.id).all
		@extraction_forms = StudyExtractionForm.where(:study_id => @study.id).all   
		render :pdf => @study_title, :template => 'studies/show_print.html.erb', :layout => "print", :disable_javascript => true, :header => {:center => "SRDR Extracted Study Data"}
 	end
  
  
	  # shows list of studies for the project with id = params[:project_id]
	  def index
	    	@studies = Study.where(:project_id => params[:project_id])
		@project = Project.find(params[:project_id])
		@project_ready_for_studies = Project.is_ready_for_studies(@project.id)
		@project_extraction_forms = @project.extraction_forms
		@extraction_forms = @project_extraction_forms
		# get current user extraction_forms to show number available
		if current_user.nil?
			@user_extraction_forms = nil
		else
			@extraction_form_list_array = Study.get_extraction_form_list_array(params[:project_id])	
			@user_extraction_forms = @extraction_form_list_array
		end
 	 end

	  # displays study summary page. 
	  # shows all data tables and section information
	  def show
=begin
	    @record = StudyRecord.new(params[:id])
=end


	    @study = Study.find(params[:id])
		@project = Project.find(params[:project_id])
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id).all	
		@study_qs = StudyKeyQuestion.where(:study_id => @study.id).all
		@study_questions = []
		@study_qs.each{|i| @study_questions << KeyQuestion.find(i.key_question_id)}
		@study_questions.sort! { |a,b| a.question_number <=> b.question_number }	
		@primary_publication = PrimaryPublication.where(:study_id => @study.id).first
		@secondary_publications = SecondaryPublication.where(:study_id => @study.id).all	
		@study_arms = Arm.where(:study_id => @study.id).all	
		@extraction_forms = StudyExtractionForm.where(:study_id => @study.id).all
		@outcomes = Outcome.where(:study_id => @study.id).all
		@adverse_events = AdverseEvent.where(:study_id => @study.id).all
		@categorical_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Categorical").all
		@continuous_outcomes = Outcome.where(:study_id => @study.id, :outcome_type => "Continuous").all		
		@extraction_forms = StudyExtractionForm.where(:study_id => @study.id).all		
		unless @extraction_forms.empty?
			# results entries
			if !@is_diagnostic
				@existing_results = @study.get_existing_results_for_session
				# session[:existing_results] = @study.get_existing_results_for_session
				ocdes = @study.get_data_entries
				@existing_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
				# session[:existing_comparisons] = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
				#session[:study_arms] = Arm.find(:all, :conditions=>["study_id = ? AND extraction_form_id=?",@study.id, @extraction_forms.first.id], :order=>"display_number ASC", :select=>["id","title","description","display_number","extraction_form_id","note","default_num_enrolled","is_intention_to_treat"])
				#session[:study_arms] = @study_arms
			# if this is a diagnostic test form, get only the comparison information associated
			# with the results
			else
				# NEEDS UPDATING
				session[:existing_results] = []
				session[:existing_comparisons] = []
				comparisons = @study.get_comparison_entries
				session[:study_arms] = nil
				session[:existing_comparisons], session[:existing_comparators] = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)
			end
		end
		# get the study title, which is the same as the primary publication for the study
		@study_title = @primary_publication.nil? ? '' : @primary_publication.title

		# render :layout=>false
 	 end

	# displays study editing page
	def edit
		if !params[:project_id] && !params[:study_id] && !params[:id]
			flash["error"] = "To add a new study, please choose a systematic review first."
			redirect_to projects_paths
		else 
	    	@study = Study.find(params[:id])
	    	#puts "---------------------\n THE STUDY ID IS #{@study.id}\n\n"
			@study_extforms = StudyExtractionForm.find(:all, :conditions=>["study_id=?",@study.id],:select=>["id","study_id","extraction_form_id"],:order=>"extraction_form_id ASC")
			@extraction_forms = Array.new

			# an array of hashes to keep track of key questions addressed by
			# each individual section
			@ef_kqs = Hash.new()
			unless @study_extforms.empty?
				@study_extforms.each do |ef|
					@ef_kqs[ef.extraction_form_id] = ExtractionForm.get_assigned_question_numbers(ef.extraction_form_id)	
		  		end
			end	  
			session[:project_id] = @study.project_id 
			@project = Project.find(@study.project_id)
			
			unless @study_extforms.empty?			
				# get the study title, which is the same as the primary publication for the study
				@study_title = PrimaryPublication.where(:study_id => @study.id).first
				@study_title = @study_title.nil? ? "" : @study_title.title.to_s	
				#@extraction_form_list_array = Study.get_extraction_form_list_array(session[:project_id])
				@extraction_forms = ExtractionForm.find(:all, :conditions=>["id in (?)",@study_extforms.collect{|x| x.extraction_form_id}])
				@current_form_id = params[:extraction_form_id].nil? ? @extraction_forms.first.id : params[:extraction_form_id].to_i
				@included_sections = ExtractionForm.get_included_sections(@current_form_id)
			end			
			# Set up the session variables
			makeStudyActive(@study)
			session[:extraction_form_id] = @current_form_id
			session[:completed_sections] = Study.get_completed_sections(@study.id, @current_form_id)
		end
  	end
 

	  # displays study extraction form page. 
	  # enables the user to view and edit the extraction forms associated with this study
	 def extractionforms
	 	@study = Study.find(params[:study_id])
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id).all		
		@project = Project.find(@study.project_id)
		session[:project_id] = @study.project_id 
		@project = Project.find(@project.id)	
		makeStudyActive(@study)

		# get the study title, which is the same as the primary publication for the study
		@study_title = PrimaryPublication.where(:study_id => @study.id).first
		@study_title = @study_title.nil? ? "" : @study_title.title.to_s
		@extraction_form_list_array = Study.get_extraction_form_list_array(@project.id)
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id).all		
		@study_extraction_form = StudyExtractionForm.new
		@ext_forms_list = @study_extforms
	 end
 
  # displays study key questions page. 
  # presents a list of key questions, where the user can choose which ones this particular study answers
 def questions
    @study = Study.find(params[:study_id])
    makeStudyActive(@study)
    session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new		
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				#@borrowed_sections[ef.extraction_form_id] = borrowed
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
	  	end
		end	
		@ef_id = params[:extraction_form_id]
		# get info on questions addressed
		@questions = @study.get_question_choices(params[:project_id])	
		# return an array telling us whether or not each question is represented by a form
		# will be a hash:  qid -> true/false
		@available = KeyQuestion.has_extraction_form_assigned(@questions)	
		@checked_ids = StudyKeyQuestion.where(:study_id=>@study.id).collect{|rec| rec.key_question_id}
	render :layout=>false
 end
 
  # displays study publication information page. 
  # contains the primary and secondary publication information and id number entry for each
	def publications
        puts ">>>>>>>>>>>>> StudiesController::destroy - enter"
        puts ">>>>>>>>>>>>> StudiesController::destroy - params[:remove_ppi] = "+params[:remove_ppi].to_s
		@study = Study.find(params[:study_id]) 
		@project = Project.find(@study.project_id)
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end
		# get info on primary publication
		@primary_publication = @study.get_primary_publication
		@primary_publication = @primary_publication.nil? ? PrimaryPublication.create(:study_id=>@study.id) : @primary_publication
        puts ">>>>>>>>>>>>> StudiesController::destroy - pulling @primary_publication_numbers on @primary_publication.id = "+@primary_publication.id.to_s
		@publication_ids = PrimaryPublicationNumber.where(:primary_publication_id => @primary_publication.id).all
		# get info on secondary publications
		@secondary_publications = @study.get_secondary_publications(@extform)
		@secondary_publication = SecondaryPublication.new
        puts ">>>>>>>>>>>>> StudiesController::destroy - exit"
	render :layout=>false
  end
  
  # displays study interventions page. 
  # contains study arm information
  def arms
      
      puts "... studies controller::arms for project #{session[:project_id]}, study #{session[:study_id]} and ef #{session[:extraction_form_id]}\n\n"
      #if @included_sections[params[:extraction_form_id].to_i].include?("arms")
      if ExtractionForm.includes_section?(params[:extraction_form_id],"arms")
          @arm = Arm.new
          @arms = Arm.where(:study_id => session[:study_id], :extraction_form_id => session[:extraction_form_id]).order("display_number ASC")  
      else
          flash["error"] = "That section is not included in the current extraction form."
          redirect_to edit_project_study_path(session[:project_id], session[:study_id])				
      end
      # Now get any additional user instructions for this section
      @extraction_form_arm_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", session[:extraction_form_id].to_s, "ARMS", "GENERAL"])
      render :layout=>false
  end
# displays study baseline characteristics page
  # contains the question builder and template sections for baseline characteristics
  def arm_details
  		begin
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			by_category = EfSectionOption.is_section_by_category?(params[:extraction_form_id], 'arm_detail')
			@data = QuestionBuilder.get_questions("arm_detail", params[:study_id], params[:extraction_form_id], {:user_assigned=>user_assigned, :is_by_arm=>by_category, :include_total=>false})
			@data_point = ArmDetailDataPoint.new

			# Now get any additional user instructions for this section
	        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ARM_DETAILS", "GENERAL"])
	        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

			#if @data[:by_arm] == true || @data[:by_outcome] == true
			if by_category
				render :action=>'question_based_section_by_category', :layout=>false
			else
				render :action=>'question_based_section', :layout=>false
			end
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
=begin
		@study = Study.find(params[:study_id])
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		unless @extraction_form.is_diagnostic
			@arms = Arm.where(:study_id=>@study.id, :extraction_form_id=>@extraction_form.id).all		
		else
			@arms = []
		end
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end
		if @included_sections[@extraction_form.id].include?("arm_details")
			@arm_detail = ArmDetail.new
			#@arm_detail_extraction_form_fields = ArmDetail.where(:extraction_form_id=>@extraction_form.id, :study_id => nil).order("question_number ASC")
			@arm_detail_extraction_form_fields = ArmDetail.where(:extraction_form_id=>@extraction_form.id).order("question_number ASC")
			#@arm_detail_custom_fields = ArmDetail.where(:study_id=>@study.id, :extraction_form_id => @extraction_form.id).order("question_number ASC")
			@arm_detail_custom_fields = ArmDetail.where(:extraction_form_id => @extraction_form.id).order("question_number ASC")
			@arm_detail_data_point = ArmDetailDataPoint.new
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end	
        # Now get any additional user instructions for this section
        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ARM_DETAILS", "GENERAL"])
        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions
        render :layout=>false
=end
  end
  	# displays the diagnostic tests page. 
  	def diagnostics
      	@study = Study.find(params[:study_id])
      	puts "............ studies_controller::arms on project "+@study.project_id.to_s+" EF id "+params[:extraction_form_id].to_s
      	@project = Project.find(@study.project_id)
      	makeStudyActive(@study)
      	session[:project_id] = @study.project_id
     	@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		
      	# get information regarding the extraction forms, pre-defined diagnostic tests and descriptions,
      	# sections in each form, sections borrowed from other forms, key questions associated with 
      	# each section, etc.
      	unless @study_extforms.empty?
          @extraction_forms,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = DiagnosticTest.get_extraction_form_information(@study_extforms,@study,@study.project_id)
      	end
        efid = params[:extraction_form_id].to_i
        # now get the diagnostic tests that have already been added to this study
        if @included_sections[efid].include?("diagnostics")
          	@index_test_list = DiagnosticTest.where(:extraction_form_id=>efid, :study_id=>@study.id, :test_type=>1)
		  	@reference_test_list = DiagnosticTest.where(:extraction_form_id=>efid, :study_id=>@study.id, :test_type=>2)
		  	@thresholds = Hash.new
		  	# gather the thresholds for each test
		  	(@index_test_list + @reference_test_list).each do |test|
		  		@thresholds[test.id] = test.diagnostic_test_thresholds
		  	end
      	else
          flash["error"] = "That section is not included in the current extraction form."
          redirect_to edit_project_study_path(params[:project_id], @study.id)				
      	end
      	# Now get any additional user instructions for this section
      	@user_instructions = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", efid, "DIAGNOSTIC_TESTS", "GENERAL"])
      	@user_instructions = @user_instructions.nil? ? "" : @user_instructions.instructions
      	render :layout=>false
  	end
	
  	# displays study design details page
  	# contains the question builder and template sections for design details	
	def design
		begin
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			@data = QuestionBuilder.get_questions("design_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned})
			@data_point = DesignDetailDataPoint.new
			
			# Now get any additional user instructions for this section
	        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "DESIGN", "GENERAL"])
	        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

			if @data[:by_arm] == true || @data[:by_outcome] == true
				render :action=>'question_based_section_by_category', :layout=>false
			else
				render :action=>'question_based_section', :layout=>false
			end
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
	end
  
  # displays study baseline characteristics page
  # contains the question builder and template sections for baseline characteristics
  def baselines
		begin
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			
			# determine if the extraction form is for diagnostic tests
			is_diagnostic = ExtractionForm.is_diagnostic?(params[:extraction_form_id])
			is_by_arm = is_diagnostic ? false : true
			is_by_dx_test = is_diagnostic ? true : false
			# Baselines should always be displayed by either arm or diagnostic test!
			@data = QuestionBuilder.get_questions("baseline_characteristic", params[:study_id], params[:extraction_form_id], {:user_assigned=>user_assigned, :is_by_arm=>is_by_arm, :is_by_diagnostic_test=>is_by_dx_test, :include_total=>true})
			@data_point = BaselineCharacteristicDataPoint.new

			# Now get any additional user instructions for this section
	        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "BASELINES", "GENERAL"])
	        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

			if @data[:by_arm] == true || @data[:by_outcome] == true || @data[:by_dx_test] == true

				render :action=>'question_based_section_by_category', :layout=>false
			else
				render :action=>'question_based_section', :layout=>false
			end
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
    end

  # displays outcome setup page - form to add new outcomes and timepoints
	def outcomes
		@study = Study.find(params[:study_id])
		@project=Project.find(params[:project_id])
		@outcome_subgroups = []
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		# get information regarding the extraction forms, pre-defined outcomes, outcome descriptions,
		# sections in each form, sections borrowed from other forms, key questions associated with 
		# each section, etc.
		#unless @study_extforms.empty?
		#	@extraction_forms,@outcome_options,@descriptions,@included_sections,@borrowed_section_names,@section_donor_ids,@kqs_per_section = Outcome.get_extraction_form_information(@study_extforms,@study,@project)
		#end
		
		#if @included_sections[@extraction_form.id].include?("outcomes")
		if ExtractionForm.includes_section?(params[:extraction_form_id],'outcomes')
			@study_arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => @extraction_form.id).all
			@outcome = Outcome.new
			@outcomes = Outcome.where(:study_id => @study.id, :extraction_form_id =>  @extraction_form.id).all
			@outcome_subgroups_hash = Outcome.get_subgroups_by_outcome(@outcomes)
			@outcome_timepoint = OutcomeTimepoint.new
			@outcome_timepoints = @outcome.outcome_timepoints
			@time_units = Outcome.get_timepoint_unit_options(@study.id)
			@editing = params[:editing]
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end
        # Now get any additional user instructions for this section
        @extraction_form_outcomes_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "OUTCOMES", "GENERAL"])
        @extraction_form_id = params[:extraction_form_id]
        render :layout=>false
	end

	# displays study outcome details page
  # contains the question builder and template sections for design details	
	def outcome_details
		begin
			@project_id = params[:project_id]
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			@data_point = OutcomeDetailDataPoint.new
			action = ''

			# Now get any additional user instructions for this section
      @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "OUTCOME_DETAILS", "GENERAL"])
      @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

			by_category = EfSectionOption.is_section_by_category?(params[:extraction_form_id], 'outcome_detail')
			if by_category
				@data = QuestionBuilder.get_questions("outcome_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned, :is_by_outcome=>true, :include_total=>false})
				action = 'question_based_section_by_category'
			else
				action = 'question_based_section'
				@data = QuestionBuilder.get_questions("outcome_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned})
			end
			render :action=>"#{action}", :layout=>false
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}\n\n"
		end
	end

	# displays study quality details page
  # contains the question builder and template sections for design details	
	def quality_details
		begin
			@project_id = params[:project_id]
			user_assigned = current_user.is_assigned_to_project(params[:project_id])
			@data_point = QualityDetailDataPoint.new
			action = ''

			# Now get any additional user instructions for this section
      @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "QUALITY", "GENERAL"])
      @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

			by_category = EfSectionOption.is_section_by_category?(params[:extraction_form_id], 'quality_detail')
			if by_category
				@data = QuestionBuilder.get_questions("quality_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned, :is_by_outcome=>true, :include_total=>false})
				action = 'question_based_section_by_category'
			else
				action = 'question_based_section'
				@data = QuestionBuilder.get_questions("quality_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned})
			end
			render :action=>"#{action}", :layout=>false
		rescue Exception => e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}\n\n"
		end
	end

    # displays study diagnostic test details page
    # contains the question builder and template sections for diagnostic test details
    def diagnostic_test_details
        begin
            @project_id = params[:project_id]
            user_assigned = current_user.is_assigned_to_project(params[:project_id])
            @data_point = DiagnosticTestDetailDataPoint.new
            action = ''
            by_category = EfSectionOption.is_section_by_category?(params[:extraction_form_id], 'diagnostic_test_detail')
            if by_category
                @data = QuestionBuilder.get_questions("diagnostic_test_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned, :is_by_diagnostic_test=>true, :include_total=>false})
                action = 'question_based_section_by_category'
            else
                action = 'question_based_section'
                @data = QuestionBuilder.get_questions("diagnostic_test_detail", params[:study_id], params[:extraction_form_id], {:user_assigned => user_assigned})
            end
            # Now get any additional user instructions for this section
	        @ef_instruction = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "DIAGNOSTIC_TEST_DETAILS", "GENERAL"])
	        @ef_instruction = @ef_instruction.nil? ? "" : @ef_instruction.instructions

            render :action=>"#{action}", :layout=>false
        rescue Exception => e
            puts "ERROR: #{e.message}\n\n#{e.backtrace}\n\n"
        end
    end
    # displays table for each outcome
    # that enables data entry for each outcome timepoint and arm
	def results
		@study = Study.find(params[:study_id])
		if ExtractionFormSection.section_is_included("results", @study.id, params[:extraction_form_id])
			@ef = ExtractionForm.find(params[:extraction_form_id])
			@extraction_form_id = @ef.id
			@is_diagnostic = ExtractionForm.is_diagnostic?(@ef.id)
			# if this is an RCT extraction form, get the existing outcome data entries
			# and any comparison information that go along with them. 
			if !@is_diagnostic
				@existing_results = @study.get_existing_results_for_session(@ef.id)
				ocdes = @study.get_data_entries
				@existing_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(ocdes)
				@study_arms = Arm.find(:all, :conditions=>["study_id = ? AND extraction_form_id=?",@study.id, @ef.id], :order=>"display_number ASC", :select=>["id","title","description","display_number","extraction_form_id","note","default_num_enrolled","is_intention_to_treat"])
			# if this is a diagnostic test form, get only the comparison information associated
			# with the results
			else
				@existing_results = []
				@existing_comparisons = []
				comparisons = @study.get_comparison_entries
				@study_arms = nil
				@existing_comparisons, @existing_comparators = OutcomeDataEntry.get_existing_diagnostic_comparisons_for_session(comparisons)
			end

			makeStudyActive(@study)
			session[:project_id] = @study.project_id
			@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		
			@project = Project.find(params[:project_id])
			model = @ef.is_diagnostic == true ? "DiagnosticTest" : "Arm"
			puts "\n\n-----------------\n\nStudy: #{@study.id}\nEF: #{@ef.id}\n\n"
			@arms_or_tests = eval(model).where(:study_id=>@study.id, :extraction_form_id=>@ef.id)
			@outcomes = Outcome.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",@study.id, @ef.id], :order=>["outcome_type ASC, title ASC"])
			@cont_outcomes = @outcomes.select{|x| x.outcome_type == "Continuous"}
			@cat_outcomes = @outcomes.select{|x| x.outcome_type == "Categorical"}
			@survival_outcomes = @outcomes.select{|x| ["Survival","Time to Event"].include?(x.outcome_type)}

			# FLAG TO NOT SHOW OUTCOME EDIT OPTIONS ON THE OUTCOME LIST
			@noedits = true
			# @cont_outcomes = Outcome.find(:all, :conditions=>["study_id=? AND outcome_type=? AND extraction_form_id=?",@study.id,"Continuous",@ef.id],:select=>["id","title","units","description","extraction_form_id"])
			# @cat_outcomes = Outcome.find(:all, :conditions=>["study_id=? AND outcome_type=? AND extraction_form_id=?",@study.id,"Categorical",@ef.id],:select=>["id","title","units","description","extraction_form_id"])
			# @survival_outcomes = Outcome.find(:all, :conditions=>["study_id=? AND outcome_type IN (?) AND extraction_form_id=?",@study.id,["Survival","Time to Event"],@ef.id],:select=>["id","title","units","description","extraction_form_id"])		
			@timepoints_hash = Outcome.get_timepoints_hash(@cont_outcomes + @cat_outcomes)

			# GET THE SUBGROUPS ASSOCIATED WITH THESE OUTCOMES
			@outcomes = @cont_outcomes + @cat_outcomes + @survival_outcomes
			@outcome_subgroups = Outcome.get_subgroups_by_outcome(@outcomes)
			puts "OUTCOME SUBGROUPS KEYS IS #{@outcome_subgroups.keys.join(", ")} AND THE VALUE FOR THIS ONE IS #{@outcome_subgroups["90"]}\n\n"
			@subgroups = @outcome_subgroups.to_json
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end
		render :layout=>false
 	end
  
	# shows the study comparisons page
	# @deprecated
	# no longer used - outcome comparisons and results tables are combined into 'results'
	def comparisons
		@project = Project.find(params[:project_id])
		@study = Study.find(params[:study_id])
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		@saved_comparisons = Comparison.where(:study_id=>@study.id).order("within_or_between ASC")
		@comparison_titles,@saved_measures, @saved_data_points = Comparison.get_comparison_details(@saved_comparisons)
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end
		if ExtractionFormSection.section_is_included("comparisons", @study.id, params[:extraction_form_id])
			@arms = Arm.where(:study_id=>@study.id, :extraction_form_id=>params[:extraction_form_id]).all
			@outcomes = Outcome.where(:study_id => @study.id, :extraction_form_id => params[:extraction_form_id]).all
			@outcome_timepoints = Outcome.get_timepoints_for_outcomes(@outcomes.collect{|oc| oc.id})
			@project = Project.find(params[:project_id])
			@study_arms = Arm.where(:study_id => params[:study_id], :extraction_form_id => params[:extraction_form_id]).all
			extraction_form_id = params[:extraction_form_id]
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end
		render :layout=>false
	end	
	
  # displays study adverse event page. 
  # contains table to add rows and adverse event data points to	
  def adverse
		@study = Study.find(params[:study_id])
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]

		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end
		@ef_id = params[:extraction_form_id]
		if ExtractionFormSection.section_is_included("adverse", @study.id, @ef_id)
			@suggested_ae_titles = ExtractionFormAdverseEvent.where(:extraction_form_id => @ef_id)
			puts "THERE ARE #{@suggested_ae_titles.length} SUGGESTED TITLES\n\n"
			@extraction_form = ExtractionForm.find(@ef_id)
			@project = Project.find(params[:project_id])
			@adverse_events = AdverseEvent.find(:all, :conditions=>['study_id=? AND extraction_form_id = ?', @study.id, @ef_id])
			@adverse_event = AdverseEvent.new
			@arms = Arm.find(:all, :conditions => ["study_id = ? AND extraction_form_id = ?", params[:study_id],@ef_id], :order => "display_number ASC")
			@extraction_form_adverse_event_columns = AdverseEventColumn.find(:all, :conditions => ["extraction_form_id = ?", @ef_id])
			@adverse_event_result = AdverseEventResult.new
			@num_rows = 0
			if @extraction_form.adverse_event_display_arms
				@num_rows = @num_rows + @arms.length
			end
			if @extraction_form.adverse_event_display_total
				@num_rows = @num_rows + 1
			end					
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end		
        # Now get any additional user instructions for this section
        @extraction_form_adverse_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ADVERSE", "GENERAL"])
        render :layout=>false
  end

  # displays study quality page. 
  # contains a quality dimensions data table, 
  # and a dropdown menu to choose a rating for the study in progress
   def quality
		@study = Study.find(params[:study_id])
		#makeStudyActive(@study)
		#session[:project_id] = @study.project_id
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@extraction_forms = Array.new
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end
		@ef_id = params[:extraction_form_id]
		if ExtractionFormSection.section_is_included("quality", @study.id, @ef_id)	
			session[:study_id] = @study.id
			@project = Project.find(params[:project_id])
			@exists = QualityRatingDataPoint.where(:study_id => @study.id, :extraction_form_id => @ef_id).first
			@quality_rating = @exists.nil? ? QualityRatingDataPoint.new : @exists
			@quality_dimension_field = QualityDimensionField.new
			@quality_dimension_data_point = QualityDimensionDataPoint.new
			@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @ef_id).order("question_number ASC")
		else
			flash["error"] = "That section is not included in the current extraction form."
			redirect_to edit_project_study_path(params[:project_id], @study.id)				
		end	
        # Now get any additional user instructions for this section
        @extraction_form_quality_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "QUALITY", "GENERAL"])
        render :layout=>false
	end
  
  # show the new study form page
	def new    
		@study = Study.new
		@project = Project.find(params[:project_id])
		@ready_for_studies = Project.is_ready_for_studies(params[:project_id])
		@key_questions = KeyQuestion.where(:project_id=>params[:project_id]).order("question_number ASC")
		# return an array telling us whether or not each question is represented by a form
		# will be a hash:  qid -> true/false
		@available = KeyQuestion.has_extraction_form_assigned(@key_questions)
		#added this line in case the user is coming from Home
		session[:project_id] = params[:project_id] 
        
        # Get and set bread crumb to current page
        urlhistory = session[:urlhistory]
        if urlhistory.nil?
            urlhistory = Breadcrumb.new
        end
        urlhistory.setCurrentPage("New Study","New Study","/projects/"+@project.id.to_s+"/studies/new")
        session[:urlhistory] = urlhistory
        
		render :layout=>"application"
	end

    # create a new study
    def create
		@study = Study.new
		@study.creator_id = current_user.id unless current_user.nil?
		@study.project_id = params[:project_id]
		@study.save
		#StudyAssignment.set_assignment(@study.id, @study.creator_id, 0) unless @study.creator_id.nil?

		# if the user selected a key question, then make appropriate database
		# entries for key questions and extraction forms
		unless !defined?(params[:study]) || params[:study].nil?
			@study.assign_kqs_and_efs(params[:study])
		end

		# put simple study id and title information in the session object
		makeStudyActive(@study)
		session[:project_id] = @study.project_id
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
        unless @study_extforms.empty?
    		@included_sections = Hash.new
    		@kqs_per_section = Hash.new()
    		@study_extforms.each do |ef|
    			included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
    			@included_sections[ef.extraction_form_id] = included
    			@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
    		end
    	end

    	# get info on secondary publications
    	@project = Project.find(@study.project_id)
        flash[:success] = "The study was successfully created."
    	redirect_to "/projects/#{@project.id}/studies/#{@study.id}/edit"
	end
		
    # Given a list of pubmed identifiers from the user, 
    # create a corresponding study for each. The method to 
    # do this is found in the Study model
	def create_for_pmid_list
		unless params[:pmids].empty?
			# get the information that we'll pass to the Study model
			pubmeds = params[:pmids]
			kqs = params[:study] ||= []
			project = session[:project_id]
			extraction_form = params[:extraction_form_id]
			user = current_user.id
			
			@id_list = pubmeds.split(" ")
			# create the studies for each pubmed id and get an array
			# of those that were problematic
			problem_entries = Study.create_for_pmids(@id_list, kqs, project, extraction_form, user)
			
			@studies = Study.where(:project_id => project)
			@project = Project.find(project)
			go_back = false
			if problem_entries.length == 0
				#flash[:success_html] = get_success_HTML(["All <strong>#{@id_list.length} studies</strong> were successfully created."])
				flash[:success] = "All #{@id_list.length} studies were successfully created."
			elsif problem_entries.length > 0 && problem_entries.length < @id_list.length
                successful = @id_list.length - problem_entries.length
				flash[:success] = "Successfully created #{successful.to_s} of #{@id_list.length} studies"
                puts "HAD TROUBLE GATHERING SOME OF THE PUBMED IDS\n\n"
                flash[:error] = "Could not identify the following #{problem_entries.length} studies by PubMed ID: #{problem_entries.join(", ")}"
			else
				#flash[:error_message] = "ERROR: Could not obtain information for any of the supplied PubMed IDs."
                puts "COULD NOT FIND ANY OF THE PUBMED IDS\n\n"
                flash[:error] = "Could not identify any of the supplied PubMed IDs."
                go_back = true
			end
			respond_to do |format|
				format.html{
					if go_back
                        redirect_to :back
                    else
                        redirect_to '/projects/'+@project.id.to_s+'/studies/'
                    end
				}
			end
		else
            if params[:pmids].empty?
                flash[:error] = "Please enter a list of pubmed IDs separated by at least one space or line."
			end
			redirect_to :back
		end

	end
	
  # update an existing study
  def update
    @study = Study.find(params[:id])
    @project = Project.find(@study.project_id)
		#@project = Project.find(session[:project_id])
		#@study = Study.set_study_type(params, @study)
    if @saved = @study.update_attributes(params[:study])
			questions_flag = false
			questions = get_questions_params(params)
			# if we're updating from the key question form,
			# remove previously saved questions for this study
			kq_error = false
			unless params[:updating_kq].nil?
				# if there are question parameters, save the new entries
				unless questions.empty?
					@study.assign_questions(questions, params[:extraction_form_id])
				else
					flash[:error] = "This operation is not allowed. Studies must be associated with at least one key question."
					kq_error = true
				end
			end
		end
		@study_extforms = StudyExtractionForm.where(:study_id => @study.id)
		@study_extforms.uniq!
		@extraction_forms = @study.get_extraction_forms
		@included_sections = Hash.new
		@borrowed_section_names, @section_donor_ids = [Hash.new,Hash.new]
		# an array of hashes to keep track of key questions addressed by
		# each individual section
		@kqs_per_section = Hash.new
		unless @study_extforms.empty?
			@study_extforms.each do |ef|
				tmpForm = ExtractionForm.find(ef.extraction_form_id)
				@extraction_forms << tmpForm
				included = ExtractionFormSection.get_included_sections(ef.extraction_form_id)
				borrowed = ExtractionFormSection.get_borrowed_sections(ef.extraction_form_id)
				@included_sections[ef.extraction_form_id] = included
				@borrowed_section_names[ef.extraction_form_id] = borrowed.collect{|x| x[0]}
				@section_donor_ids[ef.extraction_form_id] = borrowed.collect{|x| x[1]}
				@kqs_per_section[ef.extraction_form_id] = ExtractionFormSection.get_questions_per_section(ef.extraction_form_id,@study)
			end
		end	
        redirect_to "/projects/#{@project.id}/studies/#{@study.id}/edit"
  end
  
  # update sections as being finalized, or complete
  def finalize 	
  	#puts "STUDY ID: #{session[:study_id]}\nef_id: #{session[:extraction_form_id]}\n\n"
	@included_sections = ExtractionFormSection.get_included_sections(session[:extraction_form_id])	
	@study_note = StudyStatusNote.find(:first, :conditions=>["study_id=? AND extraction_form_id=?", session[:study_id], session[:extraction_form_id]],:select=>["note","updated_at"])
    render :layout=>false
  end

  # toggle_section_complete
  # Provide functionality to toggle the study complete or incomplete for a given extraction form. 
  # This allows users to give the project lead some idea of the progress being made.
  def toggle_section_complete
  	unless params[:ef_section].empty?
	  	study_id = params[:study_id]
	  	extraction_form_id = params[:extraction_form_id]
	  	@section = params[:ef_section]
	  	@new_status = Study.toggle_section_complete(study_id, extraction_form_id, @section, current_user.id)
	  	if @section == 'all'
	  		session[:completed_sections].keys.each do |k|
	  			puts "\n\nsetting key of #{k} to #{@new_status}\n\n"
	  			session[:completed_sections][k] = [@new_status, current_user.id]
	  		end
	  	else
		  	session[:completed_sections][@section] = [@new_status, current_user.id]
		end
	  	@finalize_tab = params[:finalize_tab] == 'true' ? true : false
  	end
  end

  # save a note provided by the data extractor that will show on the study list and give the lead some idea
  # of the current status of extraction
  def save_status_note
  	study_id = params[:study_id]
  	extraction_form_id = params[:extraction_form_id]
  	user_id = params[:user_id]
  	note = params[:note]
  	# look for an existing note that we can update
  	existing = StudyStatusNote.find(:first, :conditions=>["study_id=? AND extraction_form_id=?",params[:study_id],params[:extraction_form_id]])
  	# if an existing entry does not exist, create a new one and save the note
  	if existing.nil?
  		StudyStatusNote.create(:study_id=>study_id, :extraction_form_id=>extraction_form_id, :user_id=>user_id, :note=>note)
  	else
  		# if the incoming message is empty, destroy the existing note
  		if note.empty?
  			existing.destroy()
  		else
  			existing.note = note
  			existing.user_id = user_id
  			existing.save
  		end
  	end
  	# render a message to indicate that the operation was successful
  	@msg_type = 'success'
  	@msg_title = 'Update Received'
  	@msg_description = 'Your note was saved successfully.'
  	render 'shared/show_message.js.erb'
  end

  # destroy a study
  def destroy
  	begin
	    @study = Study.find(:first, :conditions=>["id=?",params[:id]],:select=>["id","project_id","creator_id"])
	    unless @study.nil?
		    proj_id = @study.project_id
		    @study.remove_from_key_question_junction
		    @study.remove_from_extraction_form_junction
		    # remove any baseline characteristics associated with the study
		    baselines = BaselineCharacteristicDataPoint.where(:study_id=>@study.id)
		    unless baselines.empty?
		      baselines.each do |base|
		     		base.destroy
		   		end
		 		end
		 		
		 		# remove any design details associated with the study
		 		designs = DesignDetailDataPoint.where(:study_id=>@study.id)
		 		unless designs.empty?
		 			designs.each do |des|
		 				des.destroy
		 			end
		 		end
		    @study.destroy
		end
	rescue Exception=>e  
		puts "ERROR: #{e.message}\n#{e.backtrace}\n\n"
	end
    redirect_to "/projects/#{params[:project_id]}/studies"
  end
  
    # get an array based on form parameters being submitted
    # @param [hash] form_params form parameters submitted
    # @return [array] resulting array
    def get_questions_params(form_params)
        questions = Array.new
        form_params.keys.each do |key|
            if key =~ /^question_/
                questions.push(key.sub(/question_/,""))
            end
        end
        return questions
    end

    # set the session data to nil
    # possibly deprecated?  
    def clearSessionStudyInfo
        session[:study_id] = nil
        session[:study_title] = nil
    end
  
    # make the study session active
    # possibly deprecated?
    def makeStudyActive myStudy
    	clearSessionStudyInfo()
    	session[:study_id] = myStudy.id
        @primary_pub = myStudy.get_primary_publication
        if (defined?(@primary_pub) && !@primary_pub.nil?)
        	session[:study_title] = @primary_pub.title
        else
        	session[:study_title] = "Not Entered Yet"
        end
    end

    def batch_assignment
        unless params[:project_id].nil?
            begin
                tmp = params[:file_upload][:my_file].tempfile
                t = Time.now()
                file = File.join("#{Rails.root.to_s}","public", [t.month, t.day, t.year, t.hour, t.min, t.sec].join("") + params[:file_upload][:my_file].original_filename)
                puts "------------UPLOAD------\nFile is #{file}\n"
                FileUtils.cp tmp.path, file
                puts "done uploading\n\nStarting assignment job."
                importer = AssignmentJob.new(file,params[:project_id],current_user)
                importer.run
                puts "importer is complete.\n"
                flash[:success] = "Thanks! We're working on your file now and will email you to let you know that everything goes smoothly. If so, you should see your studies within a few minutes."
                redirect_to "/projects/#{params[:project_id]}/studies"    
                #render action: "/home/study_assignment", msg: "Your file is being processed."
            rescue Exception=>e
                puts "ERROR: #{e.message}\n#{e.backtrace}"
                render :study_assignment
            end
            
        end
    end

    def simport
        user_id           = current_user.id
        project_id        = params[:project_id].to_i
        force_create      = params[:force_create]
        ef_id             = params[:simport_upload][:extraction_form_id].to_i
        section           = params[:simport_upload][:section].to_sym
        obj_file          = params[:simport_upload][:simport_file]

        # Need to convert the value received from params to proper boolean.
        force = force_create=="true" ? true : false

        begin
            # Prepare the file on the local file system.
            local_file = set_local_file(obj_file)
        rescue NoMethodError=>e
            flash.keep[:error] = ["No file provided"]
            return redirect_to "/projects/#{project_id}/edit"
        end

        # Instantiate Importer object and parse the data
        ih = RubyXLImport.new(user_id, project_id, ef_id, section, force)
        #ih = RooImport.new(user_id, project_id, ef_id, section, force)
        wb = ih.set_workbook(local_file)
        if wb == nil
            flash.keep[:error] = ih.listOf_errors
            return redirect_to "/projects/#{project_id}/edit"
        end

        ih.parse_data(wb, ['^k[ey]*[\s_-]*q[uestion]*$', 'author, year', 'pmid'])

        # Validate the workbook. If it does not pass then set flash message and
        # redirect immediately.
        workbook_is_valid = ih.validate_workbook

        if workbook_is_valid
            # Send import to the background.
            bsimport = BackgroundSimport.new

            # Delay.
            bsimport.delay.import(user_id, project_id, ef_id, section, force, local_file, current_user.email)

            # No Delay.
            # bsimport.import(user_id, project_id, ef_id, section, force, local_file, current_user.email)

            flash.keep[:success] = " File processing! Any errors will be reported via email."
        else
            flash.keep[:error] = ih.listOf_errors
            return redirect_to "/projects/#{project_id}/edit"
        end

        respond_to do |format|
            #format.html { redirect_to "/projects/#{project_id}/edit" }
            format.html { redirect_to "/projects/#{project_id}/update_existing_data" }
            format.js { render layout: false }
        end
    end

    private

        def set_local_file(obj_file)
            t = Time.new
            tmp_file = obj_file.tempfile
            orig_filename = obj_file.original_filename
            local_file = File.join("#{Rails.root.to_s}","public", [t.month, t.day, t.year, t.hour, t.min, t.sec].join("") + orig_filename)
            FileUtils.cp tmp_file, local_file

            return local_file
        end

 	protected
     	# show a different layout based on the type of request, 
     	# i.e. don't show the full page headers to a page rendered from an ajax request
     	def determined_by_request
    	  if request.xhr?
    	   return false
    	  else
    	   'application'
    	  end
     	end


end
