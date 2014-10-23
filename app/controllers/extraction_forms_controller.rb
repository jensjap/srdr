class ExtractionFormsController < ApplicationController
  	#before_filter :require_extraction_form_ownership, :only=>[:questions, :publications, :arms, :diagnostic_tests, :design, :baselines, :outcomes, :results, :comparisons,:adverse, :quality]
  	before_filter :require_lead_role, :only=>[:questions, :publications, :arms, :diagnostic_tests, :design, :baselines, :outcomes, :results, :comparisons,:adverse, :quality, :edit]
	before_filter :require_user, :except => [:show]
        before_filter :check_publication_status, :only => [:show]
  	layout :determined_by_request
	respond_to :js

	# show print layout for printing an extraction form summary or saving as PDF
	def index_pdf
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@ef_key_questions = ExtractionFormKeyQuestion.where(:extraction_form_id => @extraction_form.id).all
		@extraction_form_arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
		proj_id = @extraction_form.project_id.nil? ? 1 : @extraction_form.project_id
		@project = Project.find(proj_id)
		@sections_list = ExtractionFormSection.where(:extraction_form_id => @extraction_form.id).all.collect{|item| item.section_name}
		@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all	
		@extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all
		@saved_names = ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form.id)
		@quality_rating_fields = QualityRatingField.where(:extraction_form_id => @extraction_form.id).all 
		render :pdf => @extraction_form.title, :template => 'extraction_forms/show_print.html.erb', :layout => "print", :disable_javascript => true, :header => {:center => "SRDR Extraction Form"}
	end

	 # display all extraction forms 
	 def index
		unless params[:all].nil?
			@extraction_forms = ExtractionForm.all
			@title = "Listing All Extraction Forms"
		else
			available = User.get_available_extraction_form_ids(current_user.id)
			@extraction_forms = ExtractionForm.find(available).paginate(:page=>params[:page])
			@title = "Your Extraction Forms"
		end
	end

	 # key questions example section
	def questions
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@assigned_questions = ExtractionForm.get_assigned_key_questions(params[:extraction_form_id])
		@key_questions = KeyQuestion.where(:project_id=>params[:project_id])
		
		# get information regarding which questions are still available, and which have been assigned 
		# to other extraction forms
		available_question_info = ExtractionForm.get_available_questions(params[:project_id],params[:extraction_form_id])
		
		@available_questions = available_question_info[0]
		@assigned_to_other = available_question_info[1]
	end
  
	# the function to assign key questions to an extraction form
	# remove any previously saved records for this extraction form and save the new entries
	def assign_key_questions
		# get the extraction form id
		ef_id = params[:extraction_form_id]
		error = false
				
		unless params[:extraction_form_key_questions].nil?
			# remove the previous entries for this form
			entries = ExtractionFormKeyQuestion.where(:extraction_form_id => ef_id)
			unless entries.empty?
				entries.each do |entry|
					entry.destroy
				end
			end
			
			# add in the new entries for the form
			params[:extraction_form_key_questions].keys.each do |key|
				kqid = params[:extraction_form_key_questions][key]
				tmp = ExtractionFormKeyQuestion.new(:extraction_form_id=>ef_id, :key_question_id=>kqid)
				tmp.save
			end
			@message_div = 'saved_item_indicator'
			@saved = true
		else
			flash[:error] = "The operation was not allowed because each extraction form must be associated with at least one key question."
			@error_partial = "layouts/info_messages"
		end
	@error_div = "validation_message"		
		render "shared/saved.js.erb"
	end
	
	 # show extraction form publications tab
	  def publications
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => "publications").first  
	  end
  
	 # show extraction form arms tab
	  def arms
        puts "================== extraction_forms_controller::arms"
	  	@arms = ExtractionFormArm.where(:extraction_form_id => params[:extraction_form_id])
	  	@efid = params[:extraction_form_id]
	  	@extraction_form_arm = ExtractionFormArm.new
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => "arms").first
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@project = Project.find(@extraction_form.project_id)
		@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"arms")
		@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"ExtractionFormArm")
        # Get ARMS instructions
        @extraction_form_arm_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ARMS", "GENERAL"])
        if @extraction_form_arm_instr.nil?
            @extraction_form_arm_instr = EfInstruction.new
        end
  end  

  # diagnostic test suggestions for extraction form
  def diagnostic_tests
  	puts "====================== extraction_forms_controller::diagnostic_tests"
  	@efid = params[:extraction_form_id].to_i
  	@extraction_form = ExtractionForm.find(@efid)
  	@index_test_list = ExtractionFormDiagnosticTest.where(:extraction_form_id=>@efid, :test_type=>1)
  	@reference_test_list = ExtractionFormDiagnosticTest.where(:extraction_form_id=>@efid, :test_type=>2)
  	instructions = EfInstruction.find(:first, :conditions=>["ef_id=? AND section=? AND data_element=?",@efid,"DIAGNOSTIC_TESTS","GENERAL"])
  	@ef_user_instructions = instructions.nil? ? nil : instructions.instructions
  end

	 # question builder for a specified data model in the extraction form  
	def question_builder
        begin
            puts "================== extraction_forms_controller::question_builder"
            @model_name = params[:model]
            @model = @model_name.dup  # this can be done away with but need to find all occurances and switch them to @model_name
            @model_title = @model_name.split("_").collect{|x| x.capitalize}.join(" ")
            class_name = @model_title.gsub(" ", "")
            @model_obj = eval(class_name).new
            @editing = true

            section_lookup = {'baseline_characteristic'=>'baselines', 'design_detail' => 'design', 'arm_detail'=>'arm_details', 'outcome_detail'=>'outcome_details', 'diagnostic_test_detail'=>'diagnostic_test_details', 'quality_detail'=>'quality'}
    		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => section_lookup[@model_name]).first 
    		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
    		@extraction_form_id = @extraction_form.id
    		@questions = eval(class_name).where(:extraction_form_id => params[:extraction_form_id]).order("question_number ASC")
    		@section = section_lookup[@model_name]
            
            # get user-instuctions defined by the extraction form creator
            @ef_user_instructions = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, @section.upcase, "GENERAL"])
            @ef_user_instructions = @ef_user_instructions.nil? ? "" : @ef_user_instructions.instructions

            @possibly_by_category = ["arm_detail","outcome_detail","diagnostic_test_detail","quality_detail"].include?(@model)
            puts "POSSIBLY BY CATEGORY IS #{@possibly_by_category}\n@model is #{@model}\n\n"
            @by_category = @possibly_by_category ? (EfSectionOption.is_section_by_category?(@extraction_form.id, @model) ? true : false) : false
        rescue Exception=>e
            puts "EXCEPTION: \n #{e.message}\nBACKTRACE:\n#{e.backtrace}\n\n"
        end
        page_to_render = 'question_builder'
        if @model_name=='quality_detail'
          page_to_render = 'quality_details'
        end
        render page_to_render
	end
 
	 # default outcome name input for extraction form 
	  def outcomes
        puts "================== extraction_forms_controller::outcomes"
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => "outcomes").first 
		@extraction_form_outcome_name = ExtractionFormOutcomeName.new
		@model="outcomes"
		@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"outcomes")
		if @donors.empty?
			@saved_names =  ExtractionFormOutcomeName.where(:extraction_form_id=>params[:extraction_form_id]);
		else
			@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"ExtractionFormOutcomeName")
		end
        # Get OUTCOMES instructions
        @extraction_form_outcomes_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "OUTCOMES", "GENERAL"])
        if @extraction_form_outcomes_instr.nil?
            @extraction_form_outcomes_instr = EfInstruction.new
        end
	  end
	
 # adverse events table header builder for extraction form   
	  def adverse
        puts "================== extraction_forms_controller::adverse"
		@adverse_event_column = AdverseEventColumn.new
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@project = Project.find(@extraction_form.project_id)
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => "adverse").first  
		@extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => params[:extraction_form_id]).all  
		@model="adverse_events"
		@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"adverse")
		@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"AdverseEventColumn")
		@extraction_form_adverse_event = ExtractionFormAdverseEvent.new
		@adverse_events = ExtractionFormAdverseEvent.where(:extraction_form_id=>params[:extraction_form_id])
        # Get ADVERSE instructions
        @extraction_form_adverse_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "ADVERSE", "GENERAL"])
        if @extraction_form_adverse_instr.nil?
            @extraction_form_adverse_instr = EfInstruction.new
        end
	  end
 
 # quality table header builder for extraction form   
	 def quality
        puts "================== extraction_forms_controller::quality"
		@model="quality_dimensions"
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])
		@project = Project.find(@extraction_form.project_id)
		@extraction_form_section = ExtractionFormSection.where(:extraction_form_id => params[:extraction_form_id], :section_name => "quality").first 
		@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"quality")
		if @donors.empty?
			@quality_dimension_field = QualityDimensionField.new
			@quality_dimension_fields = QualityDimensionField.where(:extraction_form_id => params[:extraction_form_id], :study_id => nil).all
			@quality_rating_field = QualityRatingField.new
			@quality_rating_fields =QualityRatingField.find(:all, :conditions => {:extraction_form_id => params[:extraction_form_id]}, :order => "display_number ASC")
		else
			@donor_ratings = ExtractionFormSectionCopy.get_donor_info(@donors,"QualityRatingField")
			@donor_dimensions = ExtractionFormSectionCopy.get_donor_info(@donors,"QualityDimensionField")
		end
        # Get QUALITY instructions
        @extraction_form_quality_instr = EfInstruction.find(:first, :conditions=>["ef_id = ? and section = ? and data_element = ?", params[:extraction_form_id].to_s, "QUALITY", "GENERAL"])
        if @extraction_form_quality_instr.nil?
            @extraction_form_quality_instr = EfInstruction.new
        end
	 end

 # display extraction form summary
	def show
		@extraction_form = ExtractionForm.find(params[:id])
		@ef_key_questions = @extraction_form.get_assigned_kq_objects
		@extraction_form_arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
		@arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
		proj_id = @extraction_form.project_id.nil? ? 1 : @extraction_form.project_id
		@project = Project.find(proj_id)
		@sections_list = ExtractionFormSection.where(:extraction_form_id => @extraction_form.id).all.collect{|item| item.section_name}
		@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all	
		@extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => @extraction_form.id)
		@saved_names = ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form.id)
		@quality_rating_fields = QualityRatingField.where(:extraction_form_id => @extraction_form.id).all
	end
  
  # show the extraction form preview window. The preview window will pop up via an ajax call on the project summary pages. 
  # this function gets all the necessary data to show in the preview window.
  def preview
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	@project = Project.find(@extraction_form.project_id) 
	@ef_key_questions = @extraction_form.get_assigned_kq_objects
	@extraction_form_arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
	@project = Project.find(@extraction_form.project_id)
	@quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all
	@extraction_form_categorical_columns = OutcomeColumn.where(:extraction_form_id => @extraction_form.id, :study_id => nil, :outcome_type => "Categorical").all
	@extraction_form_continuous_columns = OutcomeColumn.where(:extraction_form_id => @extraction_form.id, :study_id => nil, :outcome_type => "Continuous").all		
	@extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all
	@saved_names = ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form.id)
	@quality_rating_fields = QualityRatingField.where(:extraction_form_id => @extraction_form.id).all	
  end
  
 # create new form/enter title for extraction form  
  def new
    @extraction_form = ExtractionForm.new
		@project = Project.find(params[:project_id])	
		# get information about the key questions in the project
		@key_questions = KeyQuestion.where(:project_id=>@project.id).all
		available_question_info = ExtractionForm.get_available_questions(@project.id,nil)
		@available_questions = available_question_info[0]
		@assigned_questions = available_question_info[1]	
		@no_more_extraction_forms = @project.all_key_questions_accounted_for
    unless params[:errors].nil?
    	@extraction_form.errors = params[:errors]
    end
  end
  
 # display the editing mainpage for extraction form  
  def edit
    @extraction_form = ExtractionForm.find(params[:id])
	@project = Project.find(@extraction_form.project_id)
	@key_questions = KeyQuestion.where(:project_id => @project.id).order("question_number ASC")
	available_question_info = ExtractionForm.get_available_questions(@project.id,nil)
	@available_questions = available_question_info[0]
	@assigned_questions = available_question_info[1]	
	@no_more_extraction_forms = @project.all_key_questions_accounted_for
	@extraction_forms = @project.extraction_forms
    @studies = @project.studies
  end

 # save extraction form  
  def create
	  @extraction_form = ExtractionForm.new(params[:extraction_form])
	  if params[:extraction_form][:is_diagnostic] == 'true'
	  	@extraction_form.is_diagnostic = true
	  end
	  @extraction_form.is_ready = false
	  @project = Project.find(@extraction_form.project_id)	
	  @extraction_form.creator_id = current_user.id
	  @extraction_forms = ExtractionForm.where(:project_id => @project.id).all 
	  title_is_unique = false
	  if !@extraction_form.title.empty?
	  	title_is_unique = @extraction_form.is_title_unique_for_user(@extraction_form.title, current_user, false)
	  end

	  if title_is_unique && !params[:extraction_form_key_questions].nil? && @saved = @extraction_form.save
			params[:extraction_form_key_questions].keys.each do |key|
				kqid = params[:extraction_form_key_questions][key]
				tmp = ExtractionFormKeyQuestion.new(:extraction_form_id=>@extraction_form.id, :key_question_id=>kqid)
				tmp.save
			end
			
			begin
				ExtractionForm.create_included_section_fields(@extraction_form)
				ExtractionForm.set_section_options_on_create(@extraction_form)
				#ExtractionForm.create_default_questions(@extraction_form)
			rescue Exception=>e
				puts "Found an error: #{e.message}\n#{e.backtrace}\n\n"
			end

			flash[:success] = "Your extraction form was successfully initiated."
			@extraction_form_section = ExtractionFormSection.new
			@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"arms")
			@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"ExtractionFormArm")
			@arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id)
			@extraction_form_arm = ExtractionFormArm.new
			@previous_extraction_forms = ExtractionForm.find(:all,:conditions=>["project_id=? AND id <> ?", @project.id,@extraction_form.id])
			@assigned_questions_hash, @included_sections_hash,@checked_boxes = [Hash.new,Hash.new,Hash.new]
					
			# for each of the previously existing forms
			@previous_extraction_forms.each do |ef|
				# get the key questions assigned
				@assigned_questions_hash[ef.id] = ExtractionForm.get_assigned_question_numbers(ef.id)
				# get the sections included
				@included_sections_hash[ef.id] = ExtractionFormSection.get_included_sections_by_extraction_form_id(ef.id)	
				@borrowers = ExtractionFormSectionCopy.get_borrowers(@extraction_form.id)
				# determine which boxes should already be checked
				already_entered = ExtractionFormSectionCopy.get_previous_data(@extraction_form.id, ef.id)
				already_entered = already_entered.collect{|x| x.section_name}
				@checked_boxes[ef.id] = already_entered
				# get rid of key questions and publications
				@included_sections_hash[ef.id].delete_at(0)
				@included_sections_hash[ef.id].delete_at(0)
			end	
		else
			if !title_is_unique
				error_message = "You must choose a title that you have not previously used for an extraction form."
			elsif params[:extraction_form_key_questions].nil?
				error_message = "You must select at least one key question to associate with this extraction form."
			else
				error_message = get_error_HTML(@extraction_form.errors)
			end
			flash[:error] = error_message
		end
		@key_questions_assigned = Hash.new
		# get the key questions associated with each form
		@extraction_forms = ExtractionForm.where(:project_id => @project.id).all		
		unless @extraction_forms.empty?
			efids = @extraction_forms.collect{|record| record.id}
			efids.uniq!
			efids.each do |eid|
				kqs = ExtractionForm.get_assigned_question_numbers(eid)
				@key_questions_assigned[eid] = kqs.join(", ")	
			end
		end
		@key_questions = KeyQuestion.where(:project_id => @project.id).all
		available_question_info = ExtractionForm.get_available_questions(@project.id,nil)
		@available_questions = available_question_info[0]
		@assigned_questions = available_question_info[1]	
		@no_more_extraction_forms = @project.all_key_questions_accounted_for

                respond_to do |format|
		    if @saved
                        format.html { redirect_to "/projects/#{@project.id}/extraction_forms/#{@extraction_form.id}/edit" }
                        format.js   {}
		    else
			format.html { redirect_to "/projects/#{@project.id}/extraction_forms/new" }
		    end
                end
  end

  # finalize the extraction form
  def finalize
		@extraction_form = ExtractionForm.find(params[:extraction_form_id])

  end

  # toggle whether or not the extraction form is finalized.
  # when the form is finalized it will be available to users creating studies
  def toggle_finalized
  	begin
	  	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	  	if @extraction_form.is_ready ==true
	  		@extraction_form.is_ready = false
	  	else
				@extraction_form.is_ready = true  	
	  	end
	  	@extraction_form.save

	  rescue Exception => e
	  	puts "\n\nAn error has occured: #{e.message}\n\n"
	  	# NEED TO RENDER ERROR PAGES!
	  end
  end
  
 # update extraction form  
  def update
    @extraction_form = ExtractionForm.find(params[:id])
	@project = Project.find(@extraction_form.project_id)
 	original_title = @extraction_form.title
 	ef_kqs = params[:extraction_form_key_questions]
    title_is_unique = @extraction_form.is_title_unique_for_user(params[:extraction_form][:title], current_user, true)
    if title_is_unique && !ef_kqs.nil?
		@extraction_form.title = params[:extraction_form][:title]
		if params[:extraction_form][:is_diagnostic] != @extraction_form.is_diagnostic.to_s
			@extraction_form.toggle_diagnostic()
		end
		@saved = @extraction_form.save
		
		# find already existing question assignments
		existing_questions = ExtractionFormKeyQuestion.find(:all, :conditions=>["extraction_form_id=?",@extraction_form.id],:select=>["id","key_question_id"])
		#destroy old key question entries
		submitted_kqids = ef_kqs.values
		unless existing_questions.empty?
			existing_questions.each do |eq|
				puts "\n\nTESTING FOR THE KEY QUESTION WITH ID #{eq.key_question_id}\n"
				unless submitted_kqids.include?(eq.key_question_id.to_s)
					puts "this one was not submitted... destroy it."
					eq.destroy
				else
					submitted_kqids.delete(eq.key_question_id.to_s)
					puts "This one was submitted. Remove it from the submitted_kqids and the result is #{submitted_kqids.join(',')}"
				end
			end
		end

		submitted_kqids.each do |skq|
			puts "Now creating one for #{skq}\n\n"
			ExtractionFormKeyQuestion.create(:extraction_form_id=>@extraction_form.id, :key_question_id=>skq)
		end
		#@key_questions = ExtractionFormKeyQuestion.where(:extraction_form_id => @extraction_form.id)
		#@key_questions.each do |kq|
		#	puts "\n\nDestroying KQ #{kq.key_question_id} entry\n\n"
		#	kq.destroy
		#end
		
		#add selected key questions
		#ef_kqs.keys.each do |key|
		#	kqid = ef_kqs[key]
		#	tmp = ExtractionFormKeyQuestion.new(:extraction_form_id=>@extraction_form.id, :key_question_id=>kqid)
		#	tmp.save
		#end
		
		#get list of extraction forms and questions assigned to them
		@key_questions_assigned = Hash.new
		@extraction_forms = ExtractionForm.find(:all, :conditions=>["project_id=?",@project.id],:select=>["id","title","is_diagnostic","project_id","is_ready"])
		unless @extraction_forms.empty?
			efids = @extraction_forms.collect{|record| record.id}
			efids.uniq!
			efids.each do |eid|
				kqs = ExtractionForm.get_assigned_question_numbers(eid)
				@key_questions_assigned[eid] = kqs.join(", ")	
			end
		end
		@extraction_form_section = ExtractionFormSection.new
		#@donors = ExtractionFormSectionCopy.get_donor_forms(@extraction_form.id,"arms")
		#@donor_info = ExtractionFormSectionCopy.get_donor_info(@donors,"ExtractionFormArm")
	  	@arms = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id)
	  	#@extraction_form_arm = ExtractionFormArm.new
		@previous_extraction_forms = ExtractionForm.find(:all,:conditions=>["project_id = ? AND id <> ?", @project.id, @extraction_form.id])
		@assigned_questions_hash, @included_sections_hash,@checked_boxes = [Hash.new,Hash.new,Hash.new]
		# for each of the previously existing forms
		@previous_extraction_forms.each do |ef|
			# get the key questions assigned
			@assigned_questions_hash[ef.id] = ExtractionForm.get_assigned_question_numbers(ef.id)
			# get the sections included
			@included_sections_hash[ef.id] = ExtractionFormSection.get_included_sections_by_extraction_form_id(ef.id)	
		#	@borrowers = ExtractionFormSectionCopy.get_borrowers(@extraction_form.id)
			# determine which boxes should already be checked
			already_entered = ExtractionFormSectionCopy.get_previous_data(@extraction_form.id, ef.id)
			already_entered = already_entered.collect{|x| x.section_name}
			@checked_boxes[ef.id] = already_entered
			@included_sections_hash[ef.id].delete_at(0);@included_sections_hash[ef.id].delete_at(0);
		end
		flash[:success] = "Your extraction form has been updated."
	else
			#show page again
	    if !title_is_unique
			flash[:error] = "You have already defined an extraction form titled #{params[:extraction_form][:title].downcase}. Please choose a new title and try again."
		elsif params[:extraction_form_key_questions].nil?
			flash[:error] = "Please assign at least one key question to your extraction form."
		end
    end
	@key_questions = KeyQuestion.where(:project_id => @project.id).order("question_number ASC")
	available_question_info = ExtractionForm.get_available_questions(@project.id,nil)
	@available_questions = available_question_info[0]
	@assigned_questions = available_question_info[1]	
	@no_more_extraction_forms = @project.all_key_questions_accounted_for
    redirect_to "/projects/#{@project.id}/extraction_forms/#{@extraction_form.id}/edit"
  end

 # delete extraction form  
  def destroy
    @extraction_form = ExtractionForm.find(params[:id])
    @project = Project.find(@extraction_form.project_id)
    # determine if an extraction form can be deleted. It cannot be deleted if it 
    # has studies associated to it, either directly or indirectly (by being associated
    # with another extraction form borrowing information from it that has studies)
    ok_to_delete = @extraction_form.can_be_removed?
    
    if ok_to_delete
			@ef_outcome_columns = OutcomeColumn.where(:extraction_form_id => @extraction_form.id).all
			for tc in @ef_outcome_columns
				tc.destroy
			end
							
			# remove all entries in the extraction_form_sections table
			j = ExtractionFormSection.where(:extraction_form_id=>@extraction_form.id)
			j.each do |entry|
				entry.destroy
			end
			
			# update the extraction_form_key_questions table
			ef_kqs = ExtractionFormKeyQuestion.where(:extraction_form_id=>@extraction_form.id)
			ef_kqs.each do |efkq|
				efkq.destroy
			end
			
			# remove any quality dimensions associated with the extraction form.
			ef_qd = QualityDimensionField.where(:extraction_form_id=>@extraction_form.id)
			ef_qd.each do |qd|
				qd.destroy
			end
			
			# remove any quality ratings associated with the extraction form
			ef_qr = QualityRatingField.where(:extraction_form_id=>@extraction_form.id)
			ef_qr.each do |qr|
				qr.destroy
			end
			
			# remove the link between this form and any that it is inheriting information from
			ef_donor = ExtractionFormSectionCopy.where(:copied_to=>@extraction_form.id)
			ef_donor.each do |donor|
				donor.destroy
			end
			
			# remove all associated baseline characteristics
			baselines = BaselineCharacteristic.where(:extraction_form_id=>@extraction_form.id)
			unless baselines.empty?
				baselines.each do |bl|
					bl.destroy
				end
			end
			
			# remove all associated design details
			designs = DesignDetail.where(:extraction_form_id=>@extraction_form.id)
			unless designs.empty?
				designs.each do |des|
					des.destroy
				end
			end
			
	    @extraction_form.destroy
		flash[:success] = "Extraction form deleted successfully."		
	else
		flash[:error] = "You cannot delete this extraction form until any associated studies have been removed and no other extraction forms are importing data from it."	
	end

	redirect_to(project_path(@project.id) + "/extraction_forms")
  end 

# @todo describe this
 def clearSessionTemplateInfo
  	session[:extraction_form_id] = nil
  	session[:project_id] = nil
  	session[:study_id] = nil
 end

# @todo describe this
 def makeTemplateActive myTemplate
 	session[:extraction_form_id] = myTemplate.id
	session[:project_id] = nil
  	session[:study_id] = nil
 end

def toggle_section_inclusion
	section_id = params[:section_id]
	@section_name = params[:section_name]
	ef_id = params[:extraction_form_id]
	@included = params[:toggle_value] == 'true' ? true : false
	puts "THE SECTION NAME IS #{@section_name}\n\n"
	ExtractionFormSection.update(section_id, :included=>@included)
	# if the section was switched to be included, create completed_study_section entries in the database and
	# set to 'false'
	if @included
		CompleteStudySection.generate_entries(ef_id, [@section_name])
	# if the section was switched off (not included), remove any associated completed_study_section entries
	else
		CompleteStudySection.remove_entries(ef_id, [@section_name])
	end
	others_to_update = Hash.new()
	other_ids = Array.new()    # keep a record of ids of sections to update
	other_sections = Array.new()  # keep a record of complete_study_section sections to add or remove

	# ACCOUNT FOR DEPENDENCIES
	case @section_name
	# cover the relationship between outcomes, results and outcome details
	when 'outcomes'
		if @included
			arms_or_diagnostics = ExtractionFormSection.count(:conditions=>['extraction_form_id=? and section_name IN (?) and included=?',ef_id,['arms','diagnostics'],true])
            other_sections = ['results'] if arms_or_diagnostics > 0
		else
			other_sections = ["outcome_details","results"]
		end
	# cover the relationship between arms, arm_details, baseline characteristics, results
	when 'arms'
		if @included
			oc = ExtractionFormSection.find(:first, :conditions=>['extraction_form_id=? AND section_name=?',ef_id,'outcomes'], :select=>["included"])
			oc = oc.nil? ? false : oc.included
			other_sections = ['results'] if oc
			puts "trying to include results. \n\noc is #{oc}\n\n"
		else
			other_sections = ['arm_details','results','baselines']
		end
	# if results are included then arms and outcomes need to be as well
	# NOTE (there is currently no way for users to directly opt in or out of results)
	when 'results'
		if @included
			other_sections = ['arms','outcomes']
		end
	when 'baselines'
		if @included
			other_sections = ['arms']
		end
	when 'arm_details'
		puts "Found arm details request."
		if @included
			other_sections = ['arms']
		end
	when 'outcome_details'
		if @included
			other_sections = ['outcomes']
		end
	end
	other_ids = ExtractionFormSection.find(:all, :conditions=>['extraction_form_id=? AND section_name IN (?)', ef_id, other_sections],:select=>['id'])
	
	# update the other sections in the extraction form that are related to the one being changed
	unless other_ids.empty?		
		other_ids = other_ids.collect{|x| x.id}
		other_ids.map{|y| others_to_update[y] = {'included'=>@included}}
		#puts "KEYS: #{others_to_update.keys}, VALUES: #{others_to_update.values}\n\n"
		ExtractionFormSection.update(others_to_update.keys, others_to_update.values)
	end

	# update any complete_study_section entries that correspond to those related to the one being changed
	unless other_sections.empty?
		if @included
			CompleteStudySection.generate_entries(ef_id, other_sections)	
		else
			CompleteStudySection.remove_entries(ef_id, other_sections)
		end
	end
end

# toggle_section_inclusion
def toggle_by_category
	@by_category = -1
	@model = params[:model]
    puts "THE MODEL IS #{@model}\n"
	@model_title = @model.split("_").collect{|x| x.capitalize}.join(" ")
    puts "THE MODEL TITLE IS #{@model_title}\n\n"
	@extraction_form_id = params[:extraction_form_id]
	rec = EfSectionOption.get(params[:extraction_form_id], params[:model])
	unless rec.nil?
        col = case @model
        when 'arm_detail'
            "by_arm"
        when 'outcome_detail'
            "by_outcome"
        when "diagnostic_test_detail"
            "by_diagnostic_test"
        when 'quality_detail'
            'by_outcome'
        end
        puts "COL IS #{col}\n\n"
        puts "rec[col] is #{rec[col]}\n"
		@by_category = rec[col]
        puts "@by_category is #{@by_category} and the inverse is #{!@by_category}\n"

		@by_category = !@by_category
		rec[col] = @by_category
        puts "LEAVING, by category is #{rec[col]}\n\n"
		if rec.save
			puts "SAVED"
		else
			puts "NOT SAVED?"
		end
	else
		by_arm=false
		by_outcome=false
        by_diagnostic_test=false
		if @model == 'arm_detail'
			by_arm = true
		elsif @model == 'outcome_detail'
			by_outcome = true
		else
            by_diagnostic_test = true
        end
		@by_category = true
		EfSectionOption.create(:extraction_form_id=>@extraction_form_id, :section=>"#{@model}", :by_arm=>by_arm, :by_outcome=>by_outcome, :by_diagnostic_test=>by_diagnostic_test)
	end
end
 
 # updates whether to display table columns for arms and total values in the adverse events table
 # settings saved in the @extraction_form object
  def update_adverse_event_settings
	@extraction_form = ExtractionForm.find(params[:extraction_form_id])
	
	if params[:arm_or_total_selector] == "arm_and_total"
		@extraction_form.adverse_event_display_arms = true
		@extraction_form.adverse_event_display_total = true		
	elsif params[:arm_or_total_selector] == "arm"
		@extraction_form.adverse_event_display_arms = true
		@extraction_form.adverse_event_display_total = false			
	else
		@extraction_form.adverse_event_display_arms = false
		@extraction_form.adverse_event_display_total = true			
	end
	
	@study_efs = StudyExtractionForm.where(:extraction_form_id => @extraction_form.id).all
	@study_efs.each do |study_ef|
		@study = Study.find(study_ef.study_id)
		@adverse_events_old = AdverseEvent.where(:study_id => @study.id).all
		@adverse_events_old.each do |advev|
			advev.destroy
			@advev_results = AdverseEventResult.where(:adverse_event_id => advev.id).all
			@advev_results.each do |ae_result|
				ae_result.destroy
			end
		end
	end

    if @extraction_form.save
		@message_div = 'saved_item_indicator_advsettings'
		@extraction_form_adverse_event_columns = AdverseEventColumn.where(:extraction_form_id => @extraction_form.id).all
		@table_container = "adverse_event_fields_table"
		@table_partial = "adverse_event_columns/table"
    else
		@error_div = "validation_message_advsettings"
       	problem_html = create_error_message_html(@extraction_form_section.errors)
		flash[:error] = problem_html
		@error_partial = "layouts/info_messages"	
    end
	render "shared/saved.js.erb"
  end 
  
  # when creating a new extraction form and previous forms have already been saved for a 
  # given project, give the user the chance to import information from those previous forms.
  def ask_to_import_from_previous_forms
  	
  end

  # send_to_bank
  # When a user finalizes an extraction form, they have the ability to submit a copy of it to 
  # the extraction form bank for future use. 
  def send_to_bank
  	begin
		bank_params = params[:extraction_form_bank]
	  	title = bank_params[:title]
	  	description = bank_params[:description]
	  	show_to_team = bank_params[:show_to_team].nil? ? false : true
	  	show_to_world = bank_params[:show_to_world].nil? ? false : true
	  	ef_id = params[:extraction_form_id]
	  	@extraction_form = ExtractionForm.find(ef_id)
	  	@extraction_form.send_to_bank(current_user.id, title, description, show_to_team, show_to_world)
	  	@table_container = "bank_submission_form_div"
	  	@table_partial = "extraction_forms/bank_submission_form"
  	rescue Exception=>e
  		puts "\n\nERROR: #{e.message}\n\n"
  	end
  	render "shared/saved"
  end

  # update_bank
  # After a user submits an extraction form template to the extraction form bank, 
  # allow them to make edits to their submission.
  def update_bank
  	begin
		  bank_params = params[:extraction_form_bank]
	  	title = bank_params[:title]
	  	description = bank_params[:description]
	  	show_to_team = bank_params[:show_to_team].nil? ? false : true
	  	show_to_world = bank_params[:show_to_world].nil? ? false : true
	  	update_data = bank_params[:update_data].nil? ? false : true
	  	ef_id = params[:extraction_form_id]
	  	bank_id = params[:extraction_form_bank_id]
	  	existing_template = ExtractionFormTemplate.find(bank_id)
	  	if update_data
	  		# get rid of any existing template in the bank
	  		existing_template.destroy()
	  		# create the newest version
	  		@extraction_form = ExtractionForm.find(ef_id)
	  		@extraction_form.send_to_bank(current_user.id, title, description, show_to_team, show_to_world)
	  		@table_container = "bank_submission_form_div"
	  		@table_partial = "extraction_forms/bank_submission_form"
	  	else
	  		existing_template.show_to_local = show_to_team
	  		existing_template.show_to_world = show_to_world
	  		existing_template.title = title
	  		existing_template.description = description
	  		existing_template.save
	  	end
  	rescue Exception=>e
  		puts "\n\nERROR: #{e.message}\n\n"
  	end
  	render "shared/saved"
  end

  def check_publication_status
    @extraction_form = ExtractionForm.find(params[:id])

    # Return project id 1 if extraction form has no project_id value? Taken from def show
    #proj_id  = @extraction_form.project_id.nil? ? 1 : @extraction_form.project_id

    # Feels like a security problem. We'll send the user back to their homepage instead
    if @extraction_form.project_id.nil?
      store_location
      flash[:error] = ": The extraction form you requested is not associated with any project ID"
      redirect_to projects_path
    else
      proj_id  = @extraction_form.project_id
    end

    @project = Project.find(proj_id)

    _validate_project_membership(@project, current_user())

    @ef_key_questions                         = @extraction_form.get_assigned_kq_objects
    @extraction_form_arms                     = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
    @arms                                     = ExtractionFormArm.where(:extraction_form_id => @extraction_form.id).all
    @sections_list                            = ExtractionFormSection.where(:extraction_form_id => @extraction_form.id).all.collect{|item| item.section_name}
    @quality_dimension_extraction_form_fields = QualityDimensionField.where(:extraction_form_id => @extraction_form.id, :study_id => nil).all	
    @extraction_form_adverse_event_columns    = AdverseEventColumn.where(:extraction_form_id => @extraction_form.id)
    @saved_names                              = ExtractionFormOutcomeName.where(:extraction_form_id=> @extraction_form.id)
    @quality_rating_fields                    = QualityRatingField.where(:extraction_form_id => @extraction_form.id).all
  end





 	# show a different layout based on the type of request
 	# i.e. don't show full layout for an ajax request
 	protected
 	def determined_by_request
	  if request.xhr?
	    return false
	  else
	    'application'
	  end
 end
  
end

