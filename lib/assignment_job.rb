class AssignmentJob 
    require 'fileutils'
    # Read study assignments from a file and create studies accordingly
    # the file structure should be as follows:
    # COL     ITEM
    # 0       username (required)
    # 1       pubmed id (optional)
    # 2       internal id (optional)
    # 3       key question(s) (comma delimited, optional)
    # 4       title (optional)
    # 5       author (optional)
    # 6       affiliation (optional)
    # 7       journal (optional)
    # 8       year (optional)
    # 9       volume
    # 10      issue
    @@username = 0; @@pmID = 1; @@internalID = 2;
    @@kq = 3; @@title = 4; @@author = 5; @@affiliation = 6;
    @@journal = 7; @@year = 8; @@volume = 9; @@issue = 10;

    def initialize(filepath, project_id, user=nil)
        @filepath = filepath
        @project_id = project_id
        @user = user.nil? ? User.find(1) : user
        @user_map = Hash.new()
        @kq_ef_map = Hash.new()
        @kq_id_map = Hash.new()
    end

    def run    
        unless File.exists? (@filepath)
            `scp jens.jap@10.4.20.195:#{@filepath} #{@filepath}`
        end

        success_count = 0
        problem_lines = []
        warning_lines = []
        converted_path = convert_line_endings(@filepath)
        begin
            File.open(converted_path, 'r') do |file|
                lno = 0
                file.each_line do |line|#while (line = file.gets)#
                    #line.gsub!(/\r/,'')
                    #puts "line #{lno}: #{line}"
                    line_array = line.split(/\t/)
                    #puts "The array shows:#{line_array.join(',')}"
                    # if it's the first line, let's make sure they are using our required format    
                    if lno == 0                  
                     
                       unless line_array[@@pmID].downcase.starts_with?("pubmed") && 
                               line_array[@@internalID].downcase.starts_with?("internal") &&
                               line_array[@@username].downcase.match("username") &&
                               line_array[@@kq].downcase.starts_with?("key") &&
                               line_array[@@title].downcase.starts_with?("title") &&
                               line_array[@@author].downcase.starts_with?("author") &&
                               line_array[@@year].downcase.starts_with?("year")

                               problem_lines << [1, "Unrecognized file format. Please see the instructions for requirements."]
                               break
                        end
                        #puts "The first line: #{line}\n----------\n\n"
                    else 
                        # start by getting the user login and skip the line if we can't find them
                        login = line_array[@@username].to_s.gsub(/\"/,'')
                        unless login.empty?
                            curr_user = 1
                            #puts "Found login: #{login} AND #{line_array[@@username]}"
                            user_found, user_added = user_id_set?(login.strip)
                            if user_found || user_added
                                curr_user = @user_map[login]
                                if user_added
                                    warning_lines << [lno+1, "The user #{login} was not assigned to this project, but is now assigned as an editor."]
                                end
                            else
                                problem_lines << [lno+1, "Could not find a user with the login of #{login}"]
                                next
                            end

                            # Check if the title is empty. If yes, then we'll try to retrive pubmed
                            # info whenever the ID is provided
                            # the order of the returned array is the order is:
                            # title,authors,country,year,journal_title,volume,issue
                            citation = get_citation(line_array)

                            # With everything in place, create the study 
                            Study.transaction do
                                study = Study.create(:project_id => @project_id, :creator_id => curr_user)
                                ppub = PrimaryPublication.create(:study_id=>study.id,
                                    :title=>citation[:title], :author=>citation[:author],
                                    :country=>citation[:country], :year=>citation[:year],
                                    :pmid=>line_array[@@pmID].strip,:journal=>citation[:journal],
                                    :volume=>citation[:volume],:issue=>citation[:issue])
                                internalID = line_array[@@internalID].strip
                                unless internalID.blank?
                                    PrimaryPublicationNumber.create(:primary_publication_id=>ppub.id,:number=>internalID,:number_type=>'internal')
                                end                  
                                assign_key_questions(study.id, line_array[@@kq].strip)
                                #assign_study_to_users(study.id, [curr_user])
                            end
                            success_count += 1
                        else
                            problem_lines << [lno + 1, "No user was assigned to the study."]
                        end
                    end
                    lno += 1 # increment the line number
                end
                file.close
            end
        rescue Exception=>e 
            problem_lines << [1, "An error occured while reading your file. Please check the instructions to ensure that you're using the required format."]
            puts "AN ERROR OCCURED WHILE READING THE FILE: #{e.message}\n#{e.backtrace}\n\n"
        ensure
            FileUtils.rm converted_path
            FileUtils.rm @filepath
        end
        puts "\n\n----------------------\nDONE WITH ASSIGNMENT\n\n"
        puts "WARNINGS:\n"
        warning_lines.each do |w|
            puts " -> #{w[0]}: #{w[1]}\n"
        end
        puts "\n\nERRORS:\n"
        problem_lines.each do |p|
             puts " -> #{p[0]}: #{p[1]}\n"
        end
        puts "\n\n"
        begin
            puts "EMAILING NOW..."
            Notifier.study_upload_complete(@user, success_count, problem_lines, warning_lines).deliver
        rescue Exception => e
            puts "ERROR SENDING MAIL: #{e.message}\n#{e.backtrace}\n\n"
        end
    end
    handle_asynchronously :run, :run_at => Time.now() + 1
    private

    # user_id_set?
    # find the user based on the provided login 
    # Returns two boolean values:
    #   First says if the user was assigned to the project
    #   Second says if the user was added as an editor
    def user_id_set? login
        found = false
        added = false
        login.strip!
        
        if @user_map[login].nil?
            usr = User.find(:first, :conditions=>["login=?",login],:select=>[:id])
            unless usr.nil?
                found = true
                @user_map[login] = usr.id
                # also make sure the user is assigned to the project
                assigned = UserProjectRole.count(:conditions=>["user_id=? AND project_id=?",usr.id, @project_id])
                if assigned < 1
                    UserProjectRole.create(:user_id=>usr.id, :project_id=>@project_id, :role=>'editor')
                    added = true
                end
            end
        else
            found = true
        end
        return [found, added]
    end

    # get_title
    # If a title was provided for the study, return that title. 
    # If a title was not provided, check if a pubmed id was given. If so, 
    # try and fetch the information from pubmed. As a default, return '-- Not Provided --'
    # for the required fields whenever it cannot be derived.'
    def get_citation line_array
        begin
            # re-using the code in secondary publication
            # the order is title,authors,country,year,journal_title,volume,issue
            puts "----------STARTING ON CITATION...#{line_array}"
            title = line_array[@@title].nil? ? "" : line_array[@@title].strip
            pmid = line_array[@@pmID].nil? ? "" : line_array[@@pmID].strip
            puts "Title and PMID are: #{title}, #{pmid}"
            citation_list = []
            if title.blank?
                unless pmid.blank?
                    puts "title was blank."
                    citation_list = SecondaryPublication.get_summary_info_by_pmid(pmid)
                    puts "captured: #{citation_list.join(',')}"
                else
                    citation_list = ["-- No Title Entered --","","","","","",""]
                end
            else
                puts "title was not blank."
                citation_list = [title,line_array[@@author],line_array[@@affiliation],
                                 line_array[@@year],line_array[@@journal],
                                 line_array[@@volume],line_array[@@issue]]
            end
            labels = [:title,:author,:country,:year,:journal,:volume,:issue]
            return Hash[labels.zip(citation_list)]
        rescue Exception => e
            puts "ERROR WHILE FETCHING CITATION: #{e.message}\n#{e.backtrace}\n\n"
        end
    end

    # assign_key_questions
    # if a key question has an extraction form assigned to it, create the
    # assignment in the proper tables
    def assign_key_questions(study_id, kq_entry)
        kqs = kq_entry.empty? ? [] : kq_entry.gsub(/\"/,'').split(",")
        kqs.each do |kq|
            kq = kq.to_i
            if @kq_ef_map[kq].nil?
                if @kq_id_map[kq].nil?
                    kq_obj = KeyQuestion.find(:first, :conditions=>['question_number=? AND project_id=?',kq,@project_id],:select=>["id"])
                    unless kq_obj.nil? 
                        @kq_id_map[kq] = kq_obj.id 
                    end
                end
                efmap = @kq_id_map[kq].nil? ? nil : ExtractionFormKeyQuestion.find(:first, :conditions=>["key_question_id=?",@kq_id_map[kq]], :select=>["extraction_form_id"]) 
                unless efmap.nil?
                    @kq_ef_map[kq] = efmap.extraction_form_id 
                end
            end

            unless @kq_ef_map[kq].nil?
                StudyKeyQuestion.create(:study_id=>study_id, :key_question_id=>@kq_id_map[kq], :extraction_form_id=>@kq_ef_map[kq]) 
                StudyExtractionForm.create(:study_id=>study_id, :extraction_form_id=>@kq_ef_map[kq])
            end
        end
    end

    # check_line_endings
    # we ask users to upload a tab-delimited file, but the line endings may be different
    # depending on the platform used. If windows-style line endings are found, convert
    # them to \n and save the file again. Return the path that should ultimately be used for 
    # the study assignment task
    def convert_line_endings filepath
        begin
            # the default to return assuming the line endings are fine.
            new_path = filepath + ".conv"
            
            # loop through and convert any \r\n to \n
            File.open(new_path,'w') do |outfile|
                File.open(filepath, 'r') do |infile|
                    infile.each_line do |line|
                        #line = line.force_encoding("UTF-8")
                        line.encode!('UTF-16', :undef => :replace, :invalid => :replace, :replace => "")
                        line.encode!('UTF-8')
                        line.gsub!(/\"/,'')
                        puts "READING LINE #{line}\n"
                        line.gsub!(/\r\n?/,"\n")
                        outfile.write line
                    end
                    infile.close
                end
                outfile.close
            end
            #FileUtils.rm filepath
            return new_path
        rescue Exception => e
            puts "ERROR IN LINE ENDINGS: #{e.message}\n#{e.backtrace}\n"
        end
    end

    # assign_study_to_user
    # given a study id and a list of users, create UserStudy records to represent their involvement
=begin    
    def assign_study_to_users(study_id, user_ids)
        user_ids.each do |uid|
            UserStudy.create(:study_id=>study_id, :user_id=>uid)
        end
    end
=end
end
