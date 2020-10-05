class ProjectsController < ApplicationController
	before_filter :require_user, :except => [:published, :show, :api_index_published]
  before_filter :require_project_membership, :only => [:show]
	before_filter :require_lead_role, :only => [:manage,:edit,:update,:publish,:destroy, :import_new_data, :update_existing_data, :confirm_publication_request]
  before_filter :require_admin, :only => [:make_public, :show_publication_requests]
  #before_filter :require_editor_role, :only => [:show_progress]

  def api_index_published
    projects_json = {}
    @projects = Project.where(:is_public=>true).order("updated_at DESC").limit(3)
    @projects.each_with_index do |p, idx|
      projects_json[idx] = {}
      projects_json[idx][:created_at] = p.created_at
      projects_json[idx][:updated_at] = p.updated_at
      projects_json[idx][:publication_requested_at] = p.publication_requested_at
      projects_json[idx][:title] = p.title
      projects_json[idx][:description] = p.description
      projects_json[idx][:number_of_studies] = p.studies.count
      projects_json[idx][:number_of_key_questions] = p.key_questions.count
      projects_json[idx][:number_of_extraction_forms] = p.extraction_forms.count
      projects_json[idx][:url] = "https://srdr.ahrq.gov/projects/#{ p.id.to_s }"
    end
    render :json => projects_json
  end

	# index_pdf
	# show print layout for printing a project summary or saving as PDF
	def index_pdf
		@project = Project.find(params[:project_id])
		@key_questions = KeyQuestion.where(:project_id =>@project.id).all.sort_by{|obj|obj.question_number}
		@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
		@studies = Study.where(:project_id => @project.id)
		@kq_formatted_strings = Study.get_addressed_question_numbers_for_studies(@studies)			
		render :pdf => @project.title, :template => 'projects/show_print.html.erb', :layout => "print", :disable_javascript => true, :header => {:center => "SRDR Systematic Review"}
  end

  #published
  # show list of published projects, sorted by created date (todo: implement sorting on these)
  def published
  	puts "====================== calling projects::published"
    session[:items_per_page] = params[:items_per_page].nil? ? (session[:items_per_page].nil? ? 5 : session[:items_per_page]) : params[:items_per_page]
    page_num = params[:page].nil? ? 1 : params[:page].to_i
    sort_by = params[:sort_by].nil? ? 'Date Published (Recent First)' : params[:sort_by]
    puts "SORT BY IS  #{sort_by}"
    if sort_by == 'Date Published (Recent First)'
      puts "sorting by date published"
      @projects = Project.where(:is_public=>true).order("updated_at DESC").paginate(:page=>page_num, :per_page=>session[:items_per_page])
    elsif sort_by == 'Date Published (Oldest First)'
      puts "sorting by date published (oldest)"
      @projects = Project.where(:is_public=>true).order("updated_at ASC").paginate(:page=>page_num, :per_page=>session[:items_per_page])
    elsif sort_by == 'Title'
      puts "Sorting by title"
      @projects = Project.where(:is_public => true).order("title ASC").paginate(:page=>page_num, :per_page=>session[:items_per_page])
    end
    
    @ef_ids = Hash.new    # Collect extraction forms attached to each project

    @projects.each do |project|
      efs = ExtractionForm.where(:project_id => project.id).all
      if !efs.nil? && (efs.size > 0)
          # puts "........ loaded "+efs.size.to_s+" EFs for project "+project.id.to_s
          @ef_ids[project.id.to_s] = efs
      else
          puts "no efs found for project "+project.id.to_s
      end
    end
  end
  
  # index
  # aka "my work"
  # show list of publications user is involved in
  def index
    # The get_user_lead_projects and get_user_editor_projects both return nil if no projects exist 
  	@lead_projects = User.get_user_lead_projects(current_user)
  	@collab_projects = User.get_user_editor_projects(current_user)

    # Sort the projects by created_at date as default for presentation
    @lead_projects.sort!{|a, b| a.created_at <=> b.created_at} unless @lead_projects.nil?
    @collab_projects.sort!{|a, b| a.created_at <=> b.created_at} unless @collab_projects.nil?
  	if User.hasAdminRights(current_user)
  		@all_projects = Project.find(:all)
      @all_projects.sort!{|a,b| a.created_at <=> b.created_at} unless @all_projects.empty?
  	end	
    clearSessionProjectInfo()
  end

  # cancel_new
  # cancel creation of a new project
  # destroy any key questions that have already been saved
  def cancel_new
	 @unsaved_id = current_user.id * -1
		@key_questions = KeyQuestion.where(:project_id => @unsaved_id).all
		for kq in @key_questions
			kq.destroy
		end
		flash[:success_message] =  "Project creation was cancelled."
		redirect_to "/"	
  end
  
  # extraction_form_list
  # show a list of extraction forms that are associated with this project
  def extractionforms
		@project = Project.find(params[:id])
    @studies = @project.studies
		@key_questions = KeyQuestion.where(:project_id => @project.id).all	
		@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
		@no_more_extraction_forms = @project.all_key_questions_accounted_for	
		@key_questions_assigned = Hash.new

    # determine if there are templates available
    @templates_available = ExtractionFormTemplate.templates_available?(current_user)
    
		# get the key questions associated with each form
		unless @extraction_forms.empty?
			efids = @extraction_forms.collect{|record| record.id}
			efids.uniq!
			efids.each do |eid|
				kqs = ExtractionForm.get_assigned_question_numbers(eid)
				# KEEP GOING WITH THIS TO PUT qTip POPUPS ON EACH KQ NUMBER
				#for i in 0..kqs.length-1
				#	tmp = '<a href="#" class="kq_link" kq_num="' + kqs[i].to_s + '">' + kqs[i].to_s + '</a>'
				#	kqs[i] = tmp
				#end
				@key_questions_assigned[eid] = kqs.join(", ")	
			end
		end
  end
  
  # manage
  # manage users for a project 
  def manage
  	@project = Project.find(params[:project_id])
  	@project_users = User.get_users_for_project(@project.id, current_user)
  	@user_project_roles = UserProjectRole.new		
  end
  
  # studies  
  # show the list of studies for the project with id = params[:project_id]  
  def studies
    #puts ">>>>>>>>>>>>>>>>>> start in projects_controller::studies"
    #puts ">>>>>>>>>>>>>>>>>> start in projects_controller::studies on "+params[:id].to_s
    @project = Project.find(params[:id])
    @project_ready_for_studies = Project.is_ready_for_studies(@project.id)
    @for_comparison = params[:comparison].nil? ? false : params[:comparison] == "false" ? false : true
    @extraction_forms = ExtractionForm.where(:project_id => @project.id).all
    
    # determine how the studies should be displayed / sorted
    session[:items_per_page] = params[:items_per_page].nil? ? (session[:items_per_page].nil? ? 10 : session[:items_per_page]) : params[:items_per_page]
    sort_by = params[:sort_by].nil? ? 'Date Updated (Recent First)' : params[:sort_by]
    #puts "\n\n\n\n\nSORT BY IS #{sort_by}\n\n\n\n\n"
    page_num = params[:page].nil? ? 1 : params[:page].to_i
    user_type = current_user.is_lead(@project.id) ? 'lead' : current_user.is_editor(@project.id) ? 'editor' : ''
    user_type = 'lead' if current_user.is_super_admin?
    

    #puts "\n\nSORTING:\nItemsPerPage: #{session[:items_per_page]}\nSortBy: #{sort_by}\nPageNum: #{page_num}\nUserType: #{user_type}\n\n"
    # some calls will be ajax, others html
    respond_to do |format|
      format.js{
        #puts "\n\nFOUND AN AJAX CALL \n\n"
        # :studies == "listall" selects all studies to be listed - this is used in place of passing an array of study ids for the entire
        # project - for large projects this parameter list exceeds the maximum character length of the URL
        if !params[:user].nil? && params[:user].to_s == "listall"
            # construct array list of all study ids for this project
            @study_ids = Study.find(:all, :conditions=>["project_id=?",@project.id],:select=>["id"], :order=>["created_at DESC"]).collect{|x| x.id}
            @user = 'listall'
            
        else
            @study_ids = Study.find(:all, :conditions=>["project_id=? AND creator_id=?",@project.id, current_user.id], :select=>["id"], :order=>["created_at DESC"]).collect{|x| x.id}
            @user = params[:user]
            
        end
        #puts "\n\nSTUDY IDS is #{@study_ids}\n\n"
        @studies = Study.get_sorted_study_list(@project.id, @study_ids, sort_by, page_num, session[:items_per_page], user_type, current_user.id) 
        
      }
      format.html{
        #puts "\n\nFOUND AN HTML CALL\n\n"
        # :studies == "listall" selects all studies to be listed - this is used in place of passing an array of study ids for the entire
        # project - for large projects this parameter list exceeds the maximum character length of the URL
        if !params[:user].nil? && params[:user].to_s == "listall"
            # construct array list of all study ids for this project
            @study_ids = Study.find(:all, :conditions=>["project_id=?",@project.id],:select=>["id"]).collect{|x| x.id}
            @user = "listall"
            
        else
            unless params[:user].nil?
              @user = params[:user]
              @study_ids = Study.find(:all, :conditions=>["project_id=? AND creator_id=?",@project.id, current_user.id], :select=>["id"], :order=>["created_at DESC"]).collect{|x| x.id}
            else
              @study_ids = Study.find(:all, :conditions=>["project_id=?",@project.id],:select=>["id"]).collect{|x| x.id}
            end
            
        end
        @studies = Study.get_sorted_study_list(@project.id, @study_ids, sort_by, page_num, session[:items_per_page], user_type, current_user.id)    
        
      }
    end
    
    # get some supplementary information about the studies including:
    #   - any notes left by the data extractor
    #   - any alternate IDs defined for the study
    @study_notes = Study.get_notes_for_study_list(@studies.collect{|x| x.id})
    @study_completion = Study.get_completion_percentages(@studies.collect{|x| x.id})
    @alternate_ids = Hash.new()
    
    @studies.each do |stud|
      unless stud.primary_publication.nil?
          @alternate_ids[stud.id] = PrimaryPublicationNumber.where(:primary_publication_id=>stud.primary_publication.id).select(["number","number_type"]).order("number_type ASC")
        else
          @alternate_ids[stud.id] = []
        end
      end
    
    # make sure this project is active in the session
    makeProjectActive(@project)
    session[:existing_results] = []
    session[:existing_comparisons] = []
    session[:study_arms] = []
    #puts ">>>>>>>>>>>>>>>>>> end in projects_controller::studies on "+params[:id].to_s
  end
  
  # take in a simple search term from the user and use it to search their project
  def study_search
    @project = Project.find(params[:project_id])
    @project_ready_for_studies = Project.is_ready_for_studies(@project.id)
    @for_comparison = params[:comparison].nil? ? false : params[:comparison] == "false" ? false : true
    @extraction_forms = ExtractionForm.where(:project_id => @project.id).all
    
    # determine how the studies should be displayed / sorted
    session[:items_per_page] = params[:items_per_page].nil? ? (session[:items_per_page].nil? ? 10 : session[:items_per_page]) : params[:items_per_page]
    sort_by = params[:sort_by].nil? ? 'Date Updated (Recent First)' : params[:sort_by]
    #puts "\n\n\n\n\nSORT BY IS #{sort_by}\n\n\n\n\n"
    page_num = params[:page].nil? ? 1 : params[:page].to_i
    user_type = current_user.is_lead(@project.id) ? 'lead' : current_user.is_editor(@project.id) ? 'editor' : ''
    user_type = 'lead' if current_user.is_super_admin?
    @study_ids = Project.search(@project.id, params[:search_term],current_user)
    
    unless @study_ids.empty?
      @studies = Study.get_sorted_study_list(@project.id, @study_ids, sort_by, page_num, session[:items_per_page], user_type, current_user.id)
    else
      @studies = []
    end
    @search_term = params[:search_term]
    
    # get some supplementary information about the studies including:
    #   - any notes left by the data extractor
    #   - any alternate IDs defined for the study
    unless @studies.empty?
      
      @study_notes = Study.get_notes_for_study_list(@studies.collect{|x| x.id})
      @study_completion = Study.get_completion_percentages(@studies.collect{|x| x.id})
      @alternate_ids = Hash.new()
    
      @studies.each do |stud|
        unless stud.primary_publication.nil?
          @alternate_ids[stud.id] = PrimaryPublicationNumber.where(:primary_publication_id=>stud.primary_publication.id).select(["number","number_type"]).order("number_type ASC")
        else
          @alternate_ids[stud.id] = []
        end
      end
    end
    @search_results = true
    render "studies"
  end

  # show
  # show a project summary page
  def show
    @project = Project.find(params[:id])
    makeProjectActive(@project)
    # get the key questions and format them for display in the table
    # see format_for_display in KeyQuestion model
    @key_questions = KeyQuestion.where(:project_id =>@project.id).all.sort_by{|obj|obj.question_number}
    @extraction_forms = ExtractionForm.where(:project_id => @project.id).all
    @studies = Study.where(:project_id => @project.id)
    @kq_formatted_strings = Study.get_addressed_question_numbers_for_studies(@studies)	
    # setup look up map between study and extraction form
    @study_to_ef_map = Hash.new
    @studies.each do |study|
        study_efs = StudyExtractionForm.where(:study_id => study.id)
        efids = Array.new
        study_efs.each do |sef|
            efids << sef.extraction_form_id
        end
        @study_to_ef_map[study.id] = efids 
    end
  end

  # new
  # create a new systematic review project
  def new
    @project = Project.new
		@key_question = KeyQuestion.new
		num = current_user.id * -1
		@key_questions = KeyQuestion.where(:project_id => num).all.sort_by{|obj|obj.question_number}
		@key_questions.each do |kq|
			kq.destroy
		end
		@key_questions = KeyQuestion.where(:project_id => num).all.sort_by{|obj|obj.question_number}
  end

  # edit
  # edit an existing systematic review project
  def edit
    @project = Project.find(params[:id])
    @extraction_forms = @project.extraction_forms
    @studies = @project.studies
    makeProjectActive(@project)
  	@key_questions = KeyQuestion.where(:project_id => @project.id).all.sort_by{|obj|obj.question_number}
  	@key_question = KeyQuestion.new	
    # Pickup EF information for each study - right now @studies[].extraction_form_id seem to be blank
    session[:existing_results] = []
    session[:existing_comparisons] = []
    session[:study_arms] = []
  end

  # create
  # create a new systematic review project
  def create
  	@project = Project.new(params[:project])
    if defined?(params[:key_questions]) && !params[:key_questions].nil?
	    if @saved = @project.save
				#params[:key_questions].each do |keyq|
				#	kq = KeyQuestion.find(keyq[0].to_s)
				#	kq.project_id = @project.id
				#	kq.save
				#end
				@project_kqs = KeyQuestion.where(:project_id => current_user.id * -1).all
				
				@project_kqs.each do |keyq|
					keyq.project_id = @project.id
					keyq.save
				end
				
				#save user as creator and create user role
				if !current_user.nil?
					@project.creator_id = current_user.id
					@project.save
					@user_role = UserProjectRole.new
					@user_role.user_id = current_user.id
					@user_role.project_id = @project.id
					@user_role.role = "lead"
					@user_role.save
				end

				@key_questions = KeyQuestion.where(:project_id => @project.id).all.sort_by{|obj|obj.question_number}
        @key_question = KeyQuestion.new
			else		
				params[:key_questions].each do |keyq|
					kq = KeyQuestion.find(keyq[0].to_s)
					kq.destroy
				end
				problem_html = create_error_message_html(@project.errors)
				flash[:error] = problem_html
    	end
 		else
    	flash[:error] = "- A project is required to have at least one associated key question."
    end
  end
  
  # update
  # update an existing systematic review project
  def update
    @project = Project.find(params[:id])
    makeProjectActive(@project)
    unless current_user.nil? || !@project.creator_id.nil?
		@project.creator_id = current_user.id
		end
    @key_questions = KeyQuestion.where(:project_id => @project.id).all.sort_by{|obj|obj.question_number}
		@key_question = KeyQuestion.new
		unless @key_questions.empty?
			@saved = @project.update_attributes(params[:project])
			if @saved
				if !params[:publishing].nil?
					@publishing = true
				end
				@message_div = "project_save_message"
			else
				problem_html = create_error_message_html(@project.errors)
				flash[:error_message] = problem_html
				@error_partial = "layouts/info_messages"	
				@error_div = "validation_message"
			end
		else
			flash[:error_message] = "A project is required to have at least one associated key question."
			@error_partial = "layouts/info_messages"	
			@error_div = "validation_message"
		end
  end
  
  # show_copy_form
  # show the form that the user can use to copy a project
  # @params project_id
  def show_copy_form
    # get the project
    @project = Project.find(params[:project_id])
    # determine if the project has any extraction forms or studies
    @has_efs = @project.extraction_forms.count > 0
    @has_studies = @project.studies.count > 0
  end

  # copy
  # create a copy of the project. 
  # @params project_id
  # @params copy_efs
  # @params copy_studies
  # @params new_title
  def copy
    title = params[:new_title]
    #copy_efs = params[:copy_efs].nil? ? false : true
    copy_efs = params[:copy_efs].nil? ? false : true
    copy_studies = params[:copy_studies].nil? ? false : true
    copy_study_data = params[:copy_study_data].nil? ? false : true
    project = Project.find(params[:project_id])

    unless title == project.title
      Project.init_copy(project.id, current_user.id, title,copy_efs,copy_studies,copy_study_data)
      # flash[:success] = "We're working on copying the project now and will email you to let you know that everything goes smoothly. If so, your project should appear in your list shortly."
      @original_title = project.title
      @new_title = title
      @display_partial = "projects/copy_in_progress"
      render "/shared/generic_wrapper"   
    else
      flash[:error_message] = "Please choose a different name for the project copy."
      @error_partial = "layouts/info_messages"  
      @error_div = "validation_message"
      @close_window = "modal_div"
      render 'shared/saved'
    end    
  end

  # publish
  # "publish" the project to the system, making it publicly viewable and turning on
  # the ability to track the history of changes.
  # this method shows the "publish" page
  def publish
  	@project = Project.find(params[:id])
  end
  
  def request_publication
    @project = Project.find(params[:project_id])
  end

  def confirm_publication_request
    
    @project = Project.find(params[:project_id])
    @project.publication_requested_at = Time.now 
    @project.save 
    flash[:notice] = "Thank you. Your request for publication of your SRDR project has been submitted. 
    You will receive feedback from the SRDR Administrator concerning your project's eligibility for publication
    within 48 hours."
    
    redirect_to "/projects/#{@project.id}/publish"
  end

  def show_publication_requests
    @projects = Project.find(:all, :conditions => ["is_public = ? AND publication_requested_at IS NOT NULL", false])
    @users = User.find(:all, :conditions => ["id IN (?)",@projects.collect{|x| x.creator_id}.uniq])
    render '/projects/publishing/requests'
  end

  def make_public
    Project.transaction do
      @project = Project.find(params[:project_id])  
      if !@project.is_public
        @project.is_public = true
      end
      @project.public_downloadable = true 
      if @project.save
        flash[:success] = "The project was successfully published."
      else
        flash[:notice] = "It appears something has gone wrong."
      end
    end
    redirect_to "/home/publication_requests"
  end
  
  # destroy
  # delete a systematic review project
  def destroy
    @project = Project.find(params[:id])
    UserProjectRole.remove_roles_for_project(@project.id)
	@studies = Study.where(:project_id => @project.id).all
    @project.destroy
		@studies.each do |st|
			st.destroy
		end
		clearSessionProjectInfo()
	  if !current_user.nil?
			if current_user.is_super_admin?()
				@all_projects = Project.find(:all)
			end	  
			@lead_projects = User.get_user_lead_projects(current_user)
			@collab_projects = User.get_user_editor_projects(current_user)
	  end	
	flash[:success_message] = "Project deleted successfully."
  end
  
  # makeProjectActive
  # add a project's info to the session  
  def makeProjectActive currentProject
    clearSessionProjectInfo()
  	# set the project information
    session[:project_id] = currentProject.id
  	session[:project_title] = currentProject.title
  	
  	status = currentProject.is_public
  	if status
  		session[:project_status] = "Published (public)"
  	else 
  		session[:project_status] = "Incomplete (private)"
  	end
    
    # get extraction form information
    efs = ExtractionForm.find(:all, :conditions=>['project_id=?',currentProject.id],:select=>['id','title'])
  	ef_hash = Hash.new()
    efs.each do |ef|
      ef_hash[ef.id] = ef.title
    end
    session[:extraction_forms] = ef_hash # provide extraction forms indexed by their ID and saving their title
    session[:study_id] = nil
  end
  
  # close_editor
  # close the extraction form editor
  def close_editor
		@project = Project.find(params[:project_id])
		@extraction_forms = ExtractionForm.where(:project_id => @project.id).all
  end
  
  # provide an excel-formatted file of the study summaries and data
  def export_human_readable
  	# construct the Excel file and get a list of files created
  	filenames = ExcelExport.project_to_xls(params[:project_id], current_user)
  	
    user = current_user.login
    #zipfile_name = "#{user}_project_export.zip"
    #zipfile_loc = "exports/#{user}_project_export_#{Time.now.to_i}.zip"
  	## create a zipped file to contain all exported docs
    #Zippy.create zipfile_loc do |zip|
    #	filenames.each do |file|
  	#		zip[file] = File.open("exports/#{file}")
		#	end    	
    #end
    ## provide the created zip file for download
  	#send_file zipfile_loc, :type => "application/zip", :filename => zipfile_name
  	fname = "#{user}_project_export.xls"
  	send_data(filenames, :type=>"application/xls",:filename=>fname)
  end
  
  # provide an excel file that could be usable for statistics programs etc
  def export_machine_readable
  	# construct the Excel file and get a list of files created
  	filenames = TsvExport.project_to_tsv(params[:project_id], current_user)
  	
    user = current_user.login
    #zipfile_name = "#{user}_project_export.zip"
    #zipfile_loc = "exports/#{user}_project_export_#{Time.now.to_i}.zip"
  	## create a zipped file to contain all exported docs
    #Zippy.create zipfile_loc do |zip|
    #	filenames.each do |file|
  	#		zip[file] = File.open("exports/#{}")
		#	end    	
    #end
    ## provide the created zip file for download
  	#send_file zipfile_loc, :type => "application/zip", :filename => zipfile_name
  	fname = "#{user}_project_export.xls"
  	send_data(filenames, :type=>"application/xls",:filename=>fname)
  end
  
  # -----------------------------------------------------------------------------------------------------
  # Method for setting up study comparason 
  # -----------------------------------------------------------------------------------------------------
  def comparestudies
      prj_id = params["prj_id"]
      nstudies_str = params["nstudies"]
      puts "in projects::comparestudies - prj_id "+prj_id+" N studies "+nstudies_str
  end

  # ----------------------------------------------------------------------------------------------------
  # show_progress
  # Gather project status measurements to display to project lead. Reports generated are:
  #   1. Breakdown of each section completion by user (# of studies completed / # studies total, per section)
  #   2. By study, # of users completing the section vs. # of users extracting the study
  # @params project_id  - the ID of the project we want to display
  #-----------------------------------------------------------------------------------------------------
  def show_progress
    projectID = params[:project_id]
    @project_efs = ExtractionForm.find(:all, :conditions=>['project_id=?', projectID],:select=>["id","title"])
    @project_studies = Study.find(:all, :conditions=>['project_id=?',projectID],:select=>['id','creator_id'])
    db_entries = CompleteStudySection.find(:all, :conditions=>["extraction_form_id IN (?)",@project_efs.collect{|pe| pe.id}])
    
    # split the entries into a hash indexed by the extraction form id
    @progress_by_ef = Hash.new()
    @project_efs.collect{|pef| pef.id}.each do |e|
      @progress_by_ef[e] = db_entries.select{|dbe| dbe.extraction_form_id == e}
    end
    
    # get the names of any users on the project
    project_users = UserProjectRole.find(:all, :conditions=>["project_id=?",params[:project_id]],:select=>["user_id"])
    @project_users = User.find(:all, :conditions=>["id IN (?)",project_users.collect{|x| x.user_id}], :select=>["id","email","login","fname","lname"])
  end

#  def import_new_data
#    @project_id = params[:project_id]
#    @ef_options_for_select = Project.find(@project_id).\
#        extraction_forms.map { |ef| ["#{ef.title}", ef.id] }
#    @section_options_for_select = [ ["Design Details", :DesignDetail],
#                                    ["Arm Details", :ArmDetail],
#                                    ["Diagnostic Test Details", :DiagnosticTestDetail],
#                                    ["Baseline Characteristics", :BaselineCharacteristic],
#                                    ["Outcome Details", :OutcomeDetail],
#                                    ["Adverse Events", :AdverseEvent] ]
#    @project = Project.where(["id=?", @project_id]).first
#    respond_to do |format|
#      format.js { render layout: false }
#    end
#  end

  def update_existing_data
    @project_id = params[:project_id]
    @ef_options_for_select = Project.find(@project_id).\
        extraction_forms.map { |ef| ["#{ef.title}", ef.id] }
    @ef_options_for_select << ["Create New Extraction Form", 0]
    @section_options_for_select = [ ["Design Details", :DesignDetail],
                                    ["Arms", :Arm],
                                    ["Arm Details", :ArmDetail],
                                    ["Diagnostic Tests", :DiagnosticTest],
                                    ["Diagnostic Test Details", :DiagnosticTestDetail],
                                    ["Baseline Characteristics", :BaselineCharacteristic],
                                    ["Outcomes", :Outcome],
                                    ["Outcome Details", :OutcomeDetail],
                                    ["Adverse Events", :AdverseEvent] ]
    @project = Project.where(["id=?", @project_id]).first
    respond_to do |format|
      format.js { render layout: false }
      format.html {}
    end
  end

  #-------------------------------------------------------------
  # data_request_form
  # Request to download the Excel spreadsheet corresponding to a particular project. 
  # If the project is publicly downloadable, you must agree to some terms and the data is yours.
  def data_request_form
    @project = Project.find(params[:project_id])
    @page_title = @project.title
    @request = DataRequest.find(:first, :conditions=>["user_id=? AND project_id=?",current_user.id,@project.id])    
    @extraction_forms = ExtractionForm.find(:all, :conditions=>["project_id=?",@project.id], :select=>["id,title"],:order=>["created_at ASC"])
    render "projects/data_request_form"
  end

  #-------------------------------------------------------------
  # show_data_requests
  # Display requests for user project data in Excel format for:
  #   1) projects belonging to this user
  #   2) projects this user has requested data for
  def show_data_requests
    titles = {'incoming' => "Requests for My Data",
              'outgoing' => "Data I Have Requested",
              'incopy' => "Copies of My Projects",
              'outcopy' => "Projects I Have Copied",
              'admin_incoming' => "All Data Requests",
              'admin_incopy' => "All Copy Requests"}
    
    @request_type = params[:request_type]
    @title = titles[params[:request_type]]
    @records = []
    
    user_project_ids = []
    if current_user.is_admin?
      @title = titles["admin_#{params[:request_type]}"]
      user_project_ids = Project.find(:all, :select=>['id'])
      user_project_ids = user_project_ids.empty? ? [] : user_project_ids.collect{|x| x.id}
    else
      user_project_ids = UserProjectRole.find(:all, :conditions=>["user_id=? and role = ?",current_user.id, "lead"],:select=>["project_id"])
      user_project_ids = user_project_ids.empty? ? [] : user_project_ids.collect{|x| x.project_id}
    end
    
    
    case @request_type
    when 'incoming'
      @records = user_project_ids.empty? ? [] : DataRequest.find(:all, :conditions=>["project_id IN (?)",user_project_ids])
      @projects = Project.find(:all, :conditions=>["id IN (?)",@records.collect{|x| x.project_id}])
      @users = User.find(:all, :conditions=>["id IN (?)",@records.collect{|x| x.user_id}])
    when 'outgoing'
      @records = DataRequest.find(:all, :conditions=>["user_id=?",current_user.id])
      @projects = Project.find(:all, :conditions=>["id IN (?)",@records.collect{|x| x.project_id}])
    
    when 'incopy'
      @records = ProjectCopyRequest.find(:all, :conditions=>["project_id IN (?)",user_project_ids])
      @projects = Project.find(:all, :conditions=>["id IN (?)",(@records.collect{|x| x.project_id} + @records.collect{|x| x.clone_id}).uniq])
      @users = User.find(:all, :conditions=>["id IN (?)",@records.collect{|x| x.user_id}])
    when 'outcopy'
      @records = ProjectCopyRequest.find(:all, :conditions => ["user_id = ?", current_user.id])
      @projects = Project.find(:all, :conditions=>["id IN (?)",@records.collect{|x| [x.project_id, x.clone_id]}.flatten.uniq])
    end
    render "/data_requests/show"
  end

  #--------------------------------------------------------------
  # data_request_handler
  # receive and handle form submissions from project data request forms
  def data_request_handler
    if params[:resubmission] == "true"
      # update the existing request
      @dr = DataRequest.find(:first, :conditions=>["project_id=? AND user_id=?",params[:project_id], current_user.id])
      if (Time.now() - @dr.requested_at) > 3.days
        @dr.requested_at = Time.now()
        @dr.request_count += 1
        @dr.message = params[:message]
        @dr.save
        # SEND AN EMAIL
        @message = "Your request has been updated and a new inquiry has been sent to the project team."
        Notifier.new_data_request_notification(params[:project_id]).deliver
      else
        @message = "Please allow at least 3 days before re-submitting download requests. You last submitted at: " + @dr.requested_at.to_s
      end
    else
      # create a new request
      @dr = DataRequest.create(:user_id=>current_user.id, :requested_at=>Time.now(), :request_count => 1, :project_id=>params[:project_id], :message=>params[:message])
      @message = "Your data request has been submitted."
      # SEND AN EMAIL TO THE PROJECT LEADS
      puts ("SENDING EMAIL...")
      Notifier.new_data_request_notification(params[:project_id]).deliver
    end
    @outgoing_requests = DataRequest.find(:all, :conditions=>["user_id=?",current_user.id], :order=>["requested_at DESC"])
    @projects = Project.find(:all, :conditions=>["id IN (?)", @outgoing_requests.collect{|x| x.project_id}], :select=>["id","title"])
    render "data_requests/outgoing_requests"
  end

  #--------------------------------------------------------------
  # update_data_requests
  # allows the project lead to allow or deny the downloading of their data
  def update_data_requests
    entries = params[:request_entries]
    requests = DataRequest.find(entries.keys)
    entries.each do |key,val|
      req = requests.find{|r| r.id == key.to_i}
      if val == "accept"
        req.status = "accepted"
      else
        req.status = "denied"
      end
      req.responded_at = Time.now()
      req.responder_id = current_user.id 
      req.save
      
      # send an email to let the user(s) know their request(s) were updated.
      Notifier.new_data_request_response(req.user_id, req.project_id).deliver
    end
    redirect_to "/home/data_requests"
  end

  # download
  # Download the project Excel files
  def download
    puts "ENTERED DOWNLOAD FUNCTION"
    dl_type = params[:dl_type]
    cache_path = nil
    return_file = nil

    case dl_type
    when "ef" 
      format  = params[:format]
      extraction_form_id = params[:extraction_form_id]
      cache_path = "/public/cache/projects"
      if current_user.is_assigned_to_project(params[:project_id])
        return_file = "project-#{params[:project_id]}-#{extraction_form_id}.#{format}"
      else
        project = Project.find(params[:project_id])
        return_file = project.get_download_filename(current_user.id, extraction_form_id, format)
      end
    when "supplement" 
      return_file = params[:filename]
      cache_path = "/public/reports/#{params[:project_id]}/publish/downloads"
      if !current_user.is_assigned_to_project(params[:project_id])
        project = Project.find(params[:project_id])
        return_file = project.get_download_filename(current_user.id, nil, nil, return_file)
        if return_file != params[:filename]
          cache_path = "/public/cache/projects"
        end
      end
    end
    send_file "#{Rails.root}/#{cache_path}/#{return_file}",:x_sendfile=>true 
  end

  def show_copy_request_form
    @project_title = params[:project_title]
    @project_id = params[:project_id]
  end

  # send a notification to the admin to request a copy of a published project
  def request_a_copy
    levels = params[:copy_level].split("_")
    requests_ef = levels.length >= 1
    requests_studies = levels.length >= 2
    requests_data = levels.length >= 3
    ProjectCopyRequest.create(:user_id => current_user.id,
                              :project_id => params[:project_id],
                              :include_forms => requests_ef,
                              :include_studies => requests_studies,
                              :include_data  => requests_data)
  end

  def remove_parent_association
    p = Project.find(params[:project_id])
    p.parent_id = nil 
    p.save 
  end
end
