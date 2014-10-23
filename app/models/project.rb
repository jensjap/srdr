# == Schema Information
#
# Table name: projects
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  description         :text
#  notes               :text
#  funding_source      :string(255)
#  creator_id          :integer
#  is_public           :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  contributors        :text
#  methodology         :text
#  management_file_url :string(255)
#

class Project < ActiveRecord::Base
    cattr_reader :per_page
    @@per_page = 10

    has_many :studies, :dependent=>:destroy
    has_many :key_questions, :dependent=>:destroy
    has_many :arms, :through => :studies
    accepts_nested_attributes_for :key_questions, :allow_destroy => true
    has_many :user_project_roles
    has_many :users, :through => :user_project_roles
    has_many :extraction_forms, :dependent=>:destroy
    has_many :data_requests
    validates :title, :presence => true

    # info via http://stackoverflow.com/questions/408872/rails-has-many-through-find-by-extra-attributes-in-join-model
    has_many  :lead_users, :through => :user_project_roles, :class_name => "Project", :source => :project, :conditions => ['user_project_roles.role = ?',"lead"]
    has_many  :editor_users, :through => :user_project_roles, :class_name => "Project", :source => :project, :conditions => ['user_project_roles.role = ?',"editor"]


    # search
    # find a study within a project. Users might give us titles, authors, 
    # pubmed IDs, internal IDs or names of data extractors
    # returns an array of study ids
    def self.search(project_id, search_term, user)
        puts("Entered search with term: #{search_term} for user: #{user.login}\n")
        study_ids = []
        user_search_id = 0 # set default user search to zero so we won't match if a user wasn't found
        if(user.is_lead(project_id) || user.is_super_admin?)
            study_ids = Study.find(:all, :conditions=>["project_id = ?",project_id],:select=>["id","creator_id"])
        elsif(user.is_editor(project_id))
            study_ids = Study.find(:all, :conditions=>["project_id=? AND creator_id=?",project_id,user.id],:select=>["id,creator_id"])
        end

        user = User.find(:first, :conditions=>["login LIKE ?",search_term])
        user_search_id = user.nil? ? 0 : user.id 
        if user_search_id == 0
            study_ids = study_ids.empty? ? [] : study_ids.collect{|x| x.id}
            unless study_ids.empty?
                # we will be primarily searching publication records:
                pubs = PrimaryPublication.find(:all, :conditions=>["study_id IN (?)",study_ids])
                
                # get ids with matching title term or author term or pubmedid term
                pubs = pubs.select{|x| (x.title =~ /#{search_term}/im) || (x.author =~ /#{search_term}/im) || (x.pmid =~ /#{search_term}/im)}
               
                # gather the study_ids associated with just these publications
                if pubs.empty?
                    study_ids = []
                else 
                    study_ids = pubs.collect{|p| p.study_id}.uniq 
                end
            end
        else
            study_ids = study_ids.select{|s| s.creator_id == user_search_id}
            study_ids = study_ids.empty? ? [] : study_ids.collect{|s| s.id}.uniq
        end
        return study_ids
    end

    # copy
    # Copy project information to a new project record. This will primarily
    # be used for sytematic review project updates. Also allow the user to
    # choose whether or not to copy extraction form and study information along
    # with the project details.
    # @params [string] new_title      - how to name the project copy
    # @params [boolean] copy_efs      - copy extraction forms?
    # @params [boolean] copy_studies  - copy studies?
    # @return [boolean] success       - was the copy process successful?
    def copy(user_id, new_title, copy_efs, copy_studies, copy_study_data)
        puts "\n\n---------------- In the Copy Function.----------------\n\n"
        success = false # the return value

        # define some variables to keep track of mappings between old and new objects
        #----------------------------------------------------------------------------
        kq_id_map = Hash.new()
        ef_id_map = Hash.new()
        study_id_map = Hash.new()

        # duplicate the project to a new copy, change the title and save it
        #--------------------------------------------------------------------
        new_proj = self.clone
        new_proj.title = new_title
        new_proj.creator_id = nil   # wait to assign the user until after the copy is complete
        new_proj.is_public = false
        new_proj.updated_at = nil
        new_proj.created_at = Time.now

        # copy all key questions associated with the project.
        #----------------------------------------------------
        if new_proj.save
            UserProjectRole.create(:user_id=>user_id, :project_id=>new_proj.id, :role=>"lead")
            # create the key questions for the new project
            #--------------------------------------------------------------------
            kqs = self.key_questions
            kqs.each do |kq|
                new_kq = kq.clone
                new_kq.project_id = new_proj.id
                new_kq.updated_at = nil
                new_kq.created_at = Time.now
                new_kq.save
                # keep a mapping of old key question id to new key question id
                kq_id_map[kq.id] = new_kq.id
            end

            # copy extraction forms assigned to each key question in the project
            #--------------------------------------------------------------------
            if copy_efs
                ef_id_map, ad_id_map, ad_field_map, dd_id_map, dd_field_map, bc_id_map, bc_field_map, od_id_map, od_field_map, ae_id_map, qual_id_map = ExtractionForm.copy_project_efs(user_id, kq_id_map, self.id, new_proj.id)
                if copy_studies
                    study_id_map = Study.copy_project_studies(user_id, ef_id_map, kq_id_map, self.id, new_proj.id, copy_study_data, ad_id_map, ad_field_map, dd_id_map, dd_field_map, bc_id_map, bc_field_map, od_id_map, od_field_map, ae_id_map, qual_id_map)
                end
            end
            success = true
            new_proj.creator_id = user_id
            new_proj.save  # setting the creator id will make the project
                           # appear in the user's project list
        end
        return success
    end
    handle_asynchronously :copy, :run_at => Time.now() + 1


    def self.get_status_string(id)
        @project = Project.find(id)
        if @project.is_public
            return "Complete (Public)"
        else
            return "Incomplete (Private)"
        end
    end

    def self.get_notes_string(id)
        @notes = StickyNote.where(:project_id => id).all
        return @notes.length.to_s + " Notes"
    end

    # determine whether or not every key question in the  project is
    # assigned to an extraction form. If so, users should not be able
    # to create new extraction forms for their project.
    #
    # return a boolean true or false
    def all_key_questions_accounted_for
        retVal = false;
        kqs = self.key_questions.collect{|entry| entry.id}
        kq_length = kqs.length
        junction = ExtractionFormKeyQuestion.find(:all, :conditions=>["key_question_id IN (?)", kqs])

        if kq_length == junction.length
            retVal = true;
        end
        return retVal
    end

    def self.get_project_string_from_all_projects()
        @projects = Project.all
        str = ""
        for proj in @projects
            str = str + proj.id.to_s + " "
        end
        return str
    end

    def self.get_project_string_from_lead_roles(lead_roles)
        str = ""
        for role in lead_roles
            str = str + role.project_id.to_s + " "
        end
        return str
    end

    def self.get_project_leads_string(p_id)
        @user_roles = UserProjectRole.where(:project_id =>p_id, :role => "lead").all
        @user_names = []
        for u in @user_roles
            @user = User.where(:id => u.user_id).first
            if !@user.nil?
                @user_names << @user.fname + " " + @user.lname
            end
        end
        return @user_names.to_sentence
    end

    def self.get_project_leads_array(p_id)
        @user_roles = UserProjectRole.where(:project_id =>p_id, :role => "lead").all
        return @user_roles
    end

    def self.get_project_leads_emails_array(p_id)
        @user_roles = UserProjectRole.where(:project_id =>p_id, :role => "lead").all
        @user_emails = []
        for u in @user_roles
            @user = User.find(u.user_id)
            if !@user.nil?
                @user_emails << @user.email
            end
        end
        return @user_emails
    end

    # return a boolean of whether or not a project has extraction_forms available
    # uses the get_extraction_form_list array function found in the study model
    def has_extraction_form_options
        has_extraction_form = false
        extraction_forms = Study.get_extraction_form_list_array(self.id)
        unless extraction_forms.empty?
            has_extraction_form = true
        end
        return has_extraction_form
    end

    def self.get_project_collabs_string(p_id)
        @user_roles = UserProjectRole.where(:project_id =>p_id, :role => "editor").all
        @user_names = []
        for u in @user_roles
            @user = User.find(u.user_id)
            @user_names << @user.fname + " " + @user.lname
        end
        return @user_names.to_sentence
    end

    def self.get_studies(project_id)
        return Study.where(:project_id => project_id).all
    end

    def self.get_num_studies(project)
        pid = project.id
        @studies = Study.where(:project_id => pid).all
        return @studies.length
    end

    def self.get_num_key_qs(project)
        pid = project.id
        @key_qs = KeyQuestion.where(:project_id => pid).all
        return @key_qs.length
    end

    def self.get_num_ext_forms(project)
        pid = project.id
        @ext_forms = ExtractionForm.where(:project_id => pid).all
        return @ext_forms.length
    end

    def self.get_num_kqs_with_ext_forms(project)
        pid = project.id
        @kqs = KeyQuestion.select("id").where(:project_id => pid).all
        @ext_form_kq_entries = ExtractionFormKeyQuestion.where(:key_question_id => @kqs).all
        return @ext_form_kq_entries.length
    end

    def self.get_num_kqs_without_ext_forms(project)
        pid = project.id
        @kqs = KeyQuestion.select("id").where(:project_id => pid).all
        @ext_form_kq_entries = ExtractionFormKeyQuestion.where(:key_question_id => @kqs).all
        return @kqs.length - @ext_form_kq_entries.length
    end

    def self.all_kqs_have_extforms(project)
        num = Project.get_num_kqs_without_ext_forms(project)
        if num == 0
            return true
        else
            return false
        end
    end

    def self.moveup(project_id, keyq)
        @proj = Project.find(project_id)
        keyq_id = keyq.id
        if keyq.question_number > 1
            keyq.question_number = keyq.question_number - 1
            @proj_kqs = KeyQuestion.where(:project_id => @proj.id)
            for kq in @proj_kqs
                if (kq.question_number == keyq.question_number) && (kq.id != keyq.id)
                    kq.question_number = kq.question_number + 1
                    kq.save
                end
            end
        end
        if keyq.save
            format.js {
                render :update do |page|
                page.replace_html 'key_question_table', :partial => 'key_questions/table'
                end
            }
        end
    end

    # return a unique list of all outcomes that have been entered under
    # a given project (referenced by ID)
    def self.get_outcomes_array(project_id)
        proj = Project.find(project_id)
        studies = Project.get_studies(proj)
        proj_ocs = Array.new
        oc_descriptions = Hash.new
        for study in studies
            outcomes = Outcome.where(:study_id => study.id)
            unless outcomes.empty? || outcomes.nil?
                outcomes.each do |oc|
                    proj_ocs << oc.title

                    if oc_descriptions[oc.title].nil?
                        oc_descriptions[oc.title] = [oc.description.nil? ? "" : oc.description, oc.outcome_type.nil? ? "" : oc.outcome_type]
                    end
                end
            end
        end
        proj_ocs.sort!
        proj_ocs.uniq!
        proj_ocs = proj_ocs.collect{|p| [p,p]}
        return [proj_ocs,oc_descriptions]
    end

    # return a unique list of all arms that have been entered under
    # a given project (referenced by ID).
    # We only need to return the names of the arms in the following format:
    # [[name1,name1],[name2,name2],[name3,name3]]
    def self.get_arms_array(project_id)
        proj = Project.find(project_id)
        studies = Project.get_studies(proj)
        proj_arms = Array.new
        arm_descriptions = Hash.new
        for study in studies
            records = Arm.where(:study_id => study.id).all
            proj_arms += records.collect{|x| x.title}
            unless records.empty?
                records.each do |record|
                    if arm_descriptions[record.title].nil? || arm_descriptions[record.title].empty?
                        arm_descriptions[record.title] = record.description
                    end
                end
            end
        end
        proj_arms.sort!
        proj_arms.uniq!
        proj_arms = proj_arms.collect{|x| [x,x]}
        return [proj_arms,arm_descriptions]
    end

    # get_diagnostic_tests
    # return a unique list of all of the diagnostic tests that have been entered for a given project
    # @params [integer] project_id    - the ID reference number of the project object
    # @params [integer] test_type     - index = 1, reference = 2
    # @return [array]   tests         - the array of tests
    def self.get_diagnostic_test_names(project_id, test_type)
        proj = Project.find(project_id)
        studies = Project.get_studies(proj)
        project_tests = Array.new
        test_descriptions = Hash.new
        studies.each do |study|
            records = DiagnosticTest.where(:study_id=>study.id, :test_type=>test_type)
            project_tests += records.collect{|x| x.title}
            unless records.empty?
                records.each do |record|
                    if test_descriptions[record.title].nil? || test_descriptions[record.title].empty?
                        test_descriptions[record.title] = record.description
                    end
                end
            end
        end
        project_tests.sort!
        project_tests.uniq!
        return project_tests, test_descriptions
    end

    # determine if a project is ready for studies to be extracted.
    # studies can be extracted if:
    #  - there are key questions assigned to the project
    #  - there are extraction forms for the project
    #  - each key question assigned has an extraction form assigned to it
    def self.is_ready_for_studies(proj_id)
        reasons = [];
        ready = true;

        # get the project
        proj = Project.find(proj_id);

        # if it does not have an extraction form, set ready to false and add the reason
        if proj.extraction_forms.length == 0
            ready = false;
            reasons << "There are no extraction forms associated with this project."
        end

        kqs = proj.key_questions
        # if it does not have key questions, set ready to false and add the reason
        if kqs.empty?
            ready = false;
            reasons << "There are no key questions associated with this project."
        end
        # if it has key questions, then determine if they've been accounted for by an extraction form
        #else
        #   kqids = kqs.collect{|record| record.id};
        #   num_accounted = ExtractionFormKeyQuestion.find(:all, :conditions=>["key_question_id IN (?)",kqids]).length;
        #   unless kqids.length == num_accounted
        #       ready = false
        #       reasons << "Not all key questions have been assigned to an extraction form for this project."
        #   end
        #end

        return [ready, reasons]

    end

    # format the project into a group of excel documents
    # project information (description, key questions, users)
    # extraction forms
    # studies
    # extracted data
    def to_xls

        doc = Spreadsheet::Workbook.new # start the excel document

        # create the project information worksheet
        tab1 = doc.create_worksheet :name => "Project Information"

        # write a few lines to the sheet
        tab1.row(1).concat ['This','is','file','1','row','1']
        tab1.row(2).concat ['This','is','file','1','row','2']
        tab1.row(3).concat ['This','is','file','1','row','3']

        doc2 = Spreadsheet::Workbook.new
        d2t1 = doc2.create_worksheet :name=>'P1'
        d2t1.row(0).concat ["a little somethin somethin for doc 2"]
        files = ["#{user}_ef_1.xls","#{user}_ef_2.xls" ]
        doc.write "exports/#{files[0]}"
        doc2.write "exports/#{files[1]}"
        return files
    end

    def download_excel_zip(file_list, user)
        retVal = nil
        if !file_list.empty?
            zipped = Zippy.create "exports/#{user}_project_export.zip" do |zip|
                file_list.each do |file|
                    zip[file] = File.open("exports/#{file}")
                end
            end
            retVal = zipped
        end
        return retVal
    end

    def get_download_filename(downloader_id, ef_id, format)
        request = DataRequest.find(:first, :conditions=>["user_id=? AND project_id=?", downloader_id, self.id])
        returnFile = "access_denied.txt"
        # if it's downloadable, then record the access and provide the 
        # file requested
        currentTime = Time.now()
        if self.public_downloadable
         
          DataRequest.transaction do
            if request.nil?
              request = DataRequest.create(:user_id=>downloader_id, :project_id=>self.id, :status=>"public", :requested_at=>nil, :responder_id=>nil, :responded_at=>nil, :last_download_at=>currentTime, :download_count=>1, :request_count=>0)
            else
              puts "REQUEST ID IS " + request.id.to_s 
              request.status = "public"
              request.last_download_at = currentTime
              request.download_count = request.download_count + 1
              request.save
            end
            #returnFile = "topSecret.txt"
            returnFile = "project-#{self.id}-#{ef_id}.#{format}"
          end
        # if it's not downloadable, make sure their request has been approved.
        # if approved within 1 week ago, provide the file requested. If previously
        # approved but expired, provide accessExpired.txt
        else
          if !request.nil?
            if !request.responded_at.nil?
              if request.status == "accepted"
                unless (currentTime - request.responded_at) > 1.week
                  DataRequest.transaction do 
                    request.last_download_at = currentTime
                    request.download_count = request.download_count + 1
                    request.save
                  end
                  #returnFile = "topSecret.txt"     
                  returnFile = "project-#{self.id}-#{ef_id}.#{format}"
                else
                  returnFile = "access_expired.txt"
                end
              else
                returnFile = "access_denied.txt"
              end
            end
            # if no response has been received then they 
            # are given an access denied file
          end
          # (If there is no request record then we'll just deny access)
        end
        return returnFile
    end
end
