class AdvSearchController < ApplicationController
    # index
    # display search page
    def index
        @page_title = "Advanced Search"
    end
    
    # Remove invalid characters in the search string
    def removeInvalidCharacters(searchstr)
        if searchstr.nil?
            return ""
        end
        cleanstr = searchstr.gsub(/[\x00-\x29]/,"")
        # Allow * (x2a) and ? (x3f)
        cleanstr = cleanstr.gsub(/[\x2b-\x3e]/,"")
        cleanstr = cleanstr.gsub(/[\x40-\x40]/,"")
        cleanstr = cleanstr.gsub(/[\x7b-\xff]/,"")
        return cleanstr
    end
  
    # adv_results
    def adv_results
        # Setup search parameters in Hash
        @advsearch_params = Hash.new
        # By Projects
        @advsearch_params[:advsearch_project_title] = removeInvalidCharacters(params[:advsearch_project_title])
        @advsearch_params[:advsearch_project_description] = removeInvalidCharacters(params[:advsearch_project_description])
        @advsearch_params[:advsearch_project_arm] = removeInvalidCharacters(params[:advsearch_project_arm])
        @advsearch_params[:advsearch_project_pubid] = removeInvalidCharacters(params[:advsearch_project_pubid])
        @advsearch_params[:advsearch_project_author] = removeInvalidCharacters(params[:advsearch_project_author])
        @advsearch_params[:advsearch_project_sponsor] = removeInvalidCharacters(params[:advsearch_project_sponsor])
        @advsearch_params[:advsearch_project_fromyear] = removeInvalidCharacters(params[:advsearch_project_fromyear])
        @advsearch_params[:advsearch_project_toyear] = removeInvalidCharacters(params[:advsearch_project_toyear])
        @advsearch_params[:advsearch_project_status] = removeInvalidCharacters(params[:advsearch_project_status])
        # By Publication
        @advsearch_params[:advsearch_study_pubid] = removeInvalidCharacters(params[:advsearch_study_pubid])
        @advsearch_params[:advsearch_study_title] = removeInvalidCharacters(params[:advsearch_study_title])
        @advsearch_params[:advsearch_study_journal] = removeInvalidCharacters(params[:advsearch_study_journal])
        @advsearch_params[:advsearch_study_fromyear] = removeInvalidCharacters(params[:advsearch_study_fromyear])
        @advsearch_params[:advsearch_study_toyear] = removeInvalidCharacters(params[:advsearch_study_toyear])
        # By Outcomes
        @advsearch_params[:advsearch_outcomes_title] = removeInvalidCharacters(params[:advsearch_outcomes_title])
        @advsearch_params[:advsearch_outcomes_description] = removeInvalidCharacters(params[:advsearch_outcomes_description])
        # By Adverse Events
        @advsearch_params[:advsearch_adverse_title] = removeInvalidCharacters(params[:advsearch_adverse_title])
        @advsearch_params[:advsearch_adverse_description] = removeInvalidCharacters(params[:advsearch_adverse_description])
        # By Quality Dimensions
        @advsearch_params[:advsearch_quality_dimension] = removeInvalidCharacters(params[:advsearch_quality_dimension])

        # Setup return instance variable that holds the results - initialize empty arrays
        @resultslist = Hash.new
        @resultslist["projects"] = Array.new
        @resultslist["publications"] = Array.new
        
        # Setup flag to include only public projects or both public and private belonging to the user
        is_public = !@advsearch_params[:advsearch_project_status].nil? && (@advsearch_params[:advsearch_project_status] == "1")
        if !@advsearch_params[:advsearch_project_title].nil? &&
            @advsearch_params[:advsearch_project_title].length > 0
            # Find projects by title - exclude those already in @resultslist
            tmpresults = findByProjectTitle(@resultslist["projects"],@advsearch_params[:advsearch_project_title],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_description].nil? &&
            @advsearch_params[:advsearch_project_description].length > 0
            # Find projects by description - exclude those already in @resultslist
            tmpresults = findByProjectDescription(@resultslist["projects"],@advsearch_params[:advsearch_project_description],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_arm].nil? &&
            @advsearch_params[:advsearch_project_arm].length > 0
            # Find projects by arms - exclude those already in @resultslist
            tmpresults = findByProjectArm(@resultslist["projects"],@advsearch_params[:advsearch_project_arm],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_pubid].nil? &&
            @advsearch_params[:advsearch_project_pubid].length > 0
            # Find projects by arms - exclude those already in @resultslist
            tmpresults = findByProjectPubMedID(@resultslist["projects"],@advsearch_params[:advsearch_project_pubid],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_author].nil? &&
            @advsearch_params[:advsearch_project_author].length > 0
            # Find projects by arms - exclude those already in @resultslist
            tmpresults = findByProjectAuthor(@resultslist["projects"],@advsearch_params[:advsearch_project_author],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_sponsor].nil? &&
            @advsearch_params[:advsearch_project_sponsor].length > 0
            # Find projects by sponsor - exclude those already in @resultslist
            tmpresults = findByProjectSponsor(@resultslist["projects"],@advsearch_params[:advsearch_project_sponsor],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_project_fromyear].nil? &&
            @advsearch_params[:advsearch_project_fromyear].length > 0
            # Find projects by sponsor - exclude those already in @resultslist
            tmpresults = findByProjectYear(@resultslist["projects"],@advsearch_params[:advsearch_project_fromyear],@advsearch_params[:advsearch_project_toyear],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        #---------------- Publication Adv Search --------------------
        if !@advsearch_params[:advsearch_study_pubid].nil? &&
            @advsearch_params[:advsearch_study_pubid].length > 0
            # Find publications by pub med id - exclude those already in @resultslist
            tmpresults = findByPublications(@resultslist["publications"],@advsearch_params[:advsearch_study_pubid],"PubMed ID","pmid",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["publications"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_study_title].nil? &&
            @advsearch_params[:advsearch_study_title].length > 0
            # Find publications by title - exclude those already in @resultslist
            tmpresults = findByPublications(@resultslist["publications"],@advsearch_params[:advsearch_study_title],"Title","title",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["publications"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_study_journal].nil? &&
            @advsearch_params[:advsearch_study_journal].length > 0
            # Find publications by journal - exclude those already in @resultslist
            tmpresults = findByPublications(@resultslist["publications"],@advsearch_params[:advsearch_study_journal],"Journal","journal",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["publications"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_study_fromyear].nil? &&
            @advsearch_params[:advsearch_study_fromyear].length > 0
            # Find publications by year range - exclude those already in @resultslist
            tmpresults = findByPublicationsYear(@resultslist["publications"],@advsearch_params[:advsearch_study_fromyear],@advsearch_params[:advsearch_study_toyear],is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["publications"] << projrec
                end
            end
        end
        #---------------- Outcomes Adv Search --------------------
        # TODO
        #---------------- Adverse Events Adv Search --------------------
        if !@advsearch_params[:advsearch_adverse_title].nil? &&
            @advsearch_params[:advsearch_adverse_title].length > 0
            # Find adverse events by title - exclude those already in @resultslist
            tmpresults = findByAdverseEvents(@resultslist["projects"],@advsearch_params[:advsearch_adverse_title],"Title","title",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        if !@advsearch_params[:advsearch_adverse_description].nil? &&
            @advsearch_params[:advsearch_adverse_description].length > 0
            # Find adverse events by description - exclude those already in @resultslist
            tmpresults = findByAdverseEvents(@resultslist["projects"],@advsearch_params[:advsearch_adverse_description],"Description","description",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        #---------------- Quality Adv Search --------------------
        if !@advsearch_params[:advsearch_quality_dimension].nil? &&
            @advsearch_params[:advsearch_quality_dimension].length > 0
            # Find adverse events by title - exclude those already in @resultslist
            tmpresults = findByQuality(@resultslist["projects"],@advsearch_params[:advsearch_quality_dimension],"Dimension","dimension",is_public)
            if !tmpresults.nil? && (tmpresults.size > 0)
                tmpresults.each do |projrec|
                    @resultslist["projects"] << projrec
                end
            end
        end
        
        # Iterate through the results for project and publication level data to support filtering or subselection for display
        @resultslist["projects.categories"] = categorize_projects(@resultslist["projects"])
        @resultslist["publications.categories"] = categorize_publications(@resultslist["publications"])
        puts ">>>>>>>>>>>>>>>>> resultslist pubs cat "+@resultslist["publications.categories"].to_s
        # Now save the results in the session
        session[:search_results] = @resultslist
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Title
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectTitle(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjects(excludeprjids,"Title","title",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Description
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectDescription(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjects(excludeprjids,"Description","description",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Arm
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectArm(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjectsByArms(excludeprjids,"Arms",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by PubMed ID
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectPubMedID(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjectsByPubMedID(excludeprjids,"PubMed ID",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Author
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectAuthor(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjectsByAuthor(excludeprjids,"PubMed ID",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Sponsor
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectSponsor(projects,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjects(excludeprjids,"Funding Source","funding_source",qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by year range
    #------------------------------------------------------------------------------------------------------------------
    def findByProjectYear(projects,query_fstring,query_tstring,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        fromyear = query_fstring.strip
        toyear = nil
        if query_tstring.nil?
            toyear = Time.now.year.to_s
        else
            toyear = query_tstring.strip
        end
        
        # Pull all the project ids into an exlcusion array
        excludeprjids = Array.new
        for data in projects
            proj = data[1]
            excludeprjids << proj.id
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findProjectsByYear(excludeprjids,"Year",fromyear,toyear,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find publications
    #------------------------------------------------------------------------------------------------------------------
    def findByPublications(projects,query_string,match_loc,colname,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludepubids = Array.new
        for data in projects
            publist = projrec[4] 
            pub = publist[0] 
            excludepubids << pub.pmid
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findPublications(excludepubids,match_loc,colname,qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find publications by year range
    #------------------------------------------------------------------------------------------------------------------
    def findByPublicationsYear(projects,query_fstring,query_tstring,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        fromyear = Integer(query_fstring.strip)
        toyear = fromyear
        if query_tstring.nil?
            toyear = Time.now.year
        else
            toyear = Integer(query_tstring.strip)
        end
        
        # Pull all the project ids into an exlcusion array
        excludepubids = Array.new
        for data in projects
            publist = projrec[4] 
            pub = publist[0] 
            excludepubids << pub.pmid
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findPublicationsByYear(excludepubids,"Year",fromyear,toyear,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find adverse events
    #------------------------------------------------------------------------------------------------------------------
    def findByAdverseEvents(projects,query_string,match_loc,colname,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludepubids = Array.new
        for data in projects
            publist = projrec[4] 
            pub = publist[0] 
            excludepubids << pub.pmid
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findAdverseEvents(excludepubids,match_loc,colname,qtext,is_public)
        return resultset
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find quality dimensions events
    #------------------------------------------------------------------------------------------------------------------
    def findByQuality(projects,query_string,match_loc,colname,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        
        qtext = query_string.gsub(" and "," AND ").gsub(" or "," OR ")
        # Pull all the project ids into an exlcusion array
        excludepubids = Array.new
        for data in projects
            publist = projrec[4] 
            pub = publist[0] 
            excludepubids << pub.pmid
        end
        
        # Get array of project sets - Array[Array[<hit score>,<project>,...]]
        resultset = findQuality(excludepubids,match_loc,colname,qtext,is_public)
        return resultset
    end
        
    #------------------------------------------------------------------------------------------------------------------------------------------------
    # Iterate through list of publications and pull and organize attributes into filter categories for filtered display	
    #------------------------------------------------------------------------------------------------------------------------------------------------
    def categorize_projects(projects)
        prj_categories = Hash.new
        if !projects.nil? && (projects.size > 0)
            # Projects found - sort attributes
            # Returns a hash table of <filter category>,Hash[<value>,Array[pubidx]]> in prj_categories
            # <filter category> includes "project.private.year", "project.published.year", "project.fundingsource", ...
            # use prjidx to build reference index array for faster presentation access
            prjidx = 0
            projects.each do |projrec|
                # Project record
                proj = projrec[1] 
                
                # Get year list by private/public
                if proj.is_public
                    prj_list = prj_categories["project.published.year"]
                    if prj_list.nil?
                        prj_list = Hash.new
                    end
                    idx_list = prj_list[proj.updated_at.strftime("%Y")]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [prjidx]
                    prj_list[proj.updated_at.strftime("%Y")] = idx_list
                    prj_categories["project.published.year"] = prj_list
                else
                    prj_list = prj_categories["project.private.year"]
                    if prj_list.nil?
                        prj_list = Hash.new
                    end
                    idx_list = prj_list[proj.created_at.strftime("%Y")]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [prjidx]
                    prj_list[proj.created_at.strftime("%Y")] = idx_list
                    prj_categories["project.private.year"] = prj_list
                end
                
                # Get funding source
                fsource = proj.funding_source
                if fsource.nil? ||
                    (fsource.length == 0)
                    fsource = "Not provided"
                end
                prj_list = prj_categories["project.fundingsource"]
                if prj_list.nil?
                    prj_list = Hash.new
                end
                idx_list = prj_list[fsource]
                if idx_list.nil?
                    idx_list = Array.new
                end
                idx_list = idx_list + [prjidx]
                prj_list[fsource] = idx_list
                prj_categories["project.fundingsource"] = prj_list
                
                userinfo = projrec[6] 
                # Get project organization
                if !userinfo.organization.nil? &&
                   userinfo.organization.length > 0
                    prj_list = prj_categories["userinfo.organization"]
                    if prj_list.nil?
                        prj_list = Hash.new
                    end
                    idx_list = prj_list[userinfo.organization]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [prjidx]
                    prj_list[userinfo.organization] = idx_list
                    prj_categories["userinfo.organization"] = prj_list
                end
                
                # Get project creator name
                if !userinfo.lname.nil? &&
                   userinfo.lname.length > 0
                    prj_list = prj_categories["userinfo.lname"]
                    if prj_list.nil?
                        prj_list = Hash.new
                    end
                    idx_list = prj_list[userinfo.lname]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [prjidx]
                    prj_list[userinfo.lname] = idx_list
                    prj_categories["userinfo.lname"] = prj_list
                end
                
                prjidx = prjidx + 1;
            end
        end
        
          return prj_categories
    end
    
    def categorize_publications(publications)
        pub_categories = Hash.new
        if !publications.nil? && (publications.size > 0)
            # Publications found - sort attributes
            # Returns a hash table of <filter category>,Hash[<value>,Array[pubidx]]> in pub_categories
            # <filter category> includes "pub.year", "pub.journal", "pub.pubmedid", ...
            # use pubidx to build reference index array for faster presentation access
            pubidx = 0
            publications.each do |projrec|
                # publications are single entity records attached to a project. Actual publication record is stored in the publist[0] array
                publist = projrec[4] 
                pub = publist[0] 
                
                # Get year list
                pub_list = pub_categories["pub.year"]
                if pub_list.nil?
                    pub_list = Hash.new
                end
                idx_list = pub_list[pub.year]
                if idx_list.nil?
                    idx_list = Array.new
                end
                idx_list = idx_list + [pubidx]
                pub_list[pub.year] = idx_list
                pub_categories["pub.year"] = pub_list
                
                # Get journal list
                if !pub.journal.nil?
                    pub_list = pub_categories["pub.journal"]
                    if pub_list.nil?
                        pub_list = Hash.new
                    end
                    idx_list = pub_list[pub.journal]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [pubidx]
                    pub_list[pub.journal] = idx_list
                    pub_categories["pub.journal"] = pub_list
                end
                
                # Get pmid list
                if !pub.pmid.nil?
                    pub_list = pub_categories["pub.pmid"]
                    if pub_list.nil?
                        pub_list = Hash.new
                    end
                    idx_list = pub_list[pub.pmid]
                    if idx_list.nil?
                        idx_list = Array.new
                    end
                    idx_list = idx_list + [pubidx]
                    pub_list[pub.pmid] = idx_list
                    pub_categories["pub.pmid"] = pub_list
                end
                
                pubidx = pubidx + 1;
            end
        end
      
          return pub_categories
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Parse and build SQL command
    #------------------------------------------------------------------------------------------------------------------
    def constructSQL(query_string,colname)
        # qstr is a series of space delimited terms with logic AND | OR tying each term together. Wild cards '*' are replaced with '%'
        sqlcmd = ""
        andterms = query_string.split(" AND ")
        andterms.each do |andterm|
            if sqlcmd.length > 0
                sqlcmd = sqlcmd + " AND "
            end
            sqlcmd = sqlcmd + "("
            orterms = andterm.split(" OR ")
            if orterms.length > 1
                sqlcmd2 = ""
                orterms.each do |orterm|
                    if sqlcmd2.length > 0
                        sqlcmd2 = sqlcmd2 + " OR "
                    end
                    if orterm.include? '*'
                        sqlcmd2 = sqlcmd2 + "("+colname+" LIKE '"+orterm.tr('*','%')+"')"
                    else
                        sqlcmd2 = sqlcmd2 + "("+colname+" LIKE '%"+orterm+"%')"
                    end
                end
                sqlcmd = sqlcmd + sqlcmd2
            elsif andterm.include? '*'
                sqlcmd = sqlcmd + colname+" LIKE '"+andterm.tr('*','%')+"'"
            else
                sqlcmd = sqlcmd + "("+colname+" LIKE '%"+andterm+"%')"
            end
            sqlcmd = sqlcmd + ")"
        end
        return sqlcmd
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Parse query text into search terms, ignore AND, OR, and wildcards
    #------------------------------------------------------------------------------------------------------------------
    def getQueryTerms(query_string)
        # qstr is a series of space delimited terms with logic AND | OR tying each term together. Wild cards '*' are replaced with '%'
        ret_terms = Array.new
        
        andterms = query_string.split(" AND ")
        andterms.each do |andterm|
            orterms = andterm.split(" OR ")
            if orterms.length > 1
                orterms.each do |orterm|
                    if orterm.include? '*'
                        ret_terms << orterm.tr('*',' ').strip
                    else
                        ret_terms << orterm
                    end
                end
            elsif andterm.include? '*'
                ret_terms << andterm.tr('*',' ').strip
            else
                ret_terms << andterm
            end
        end
        return ret_terms
    end
        
    #------------------------------------------------------------------------------------------------------------------------------------------------
    # Produce context text where q1 was found in tdata   
    #------------------------------------------------------------------------------------------------------------------------------------------------
    def toContextText(txtdata,qterms)
        if txtdata.nil?
            return nil
        end
        
        rawtext = txtdata.to_s
        # For each term - place a marker
        qterms.each do |q1|
            starti = 0
            ctext = rawtext.upcase
            rtext = ""
            # For each term, put a wrapper around the term [#Q...Q#]
            cqi = q1.to_s.upcase
            compstr = ctext.split(cqi)
            puts ">>>>>>>>>> toContextText - ctext "+ctext+" cqi "+cqi
            puts ">>>>>>>>>> toContextText - comps "+compstr.to_s
            if compstr.size > 1
	        compstr.each do |comp|
                    if comp.length > 0
                        rq = rawtext[(starti + comp.length)..(starti + comp.length + q1.length - 1)]
                        # copy the fragment
                        rtext = rtext + rawtext[starti..starti + comp.length - 1] + "[#Q" + rq + "Q#]"
                    else
                        rq = rawtext[starti..(starti + q1.length - 1)]
                        # copy the fragment
                        rtext = rtext + "[#Q" + rq + "Q#]"
                    end
                    starti = starti + comp.length + q1.length
                end
            else
                rtext = rawtext.to_s
            end
            puts ">>>>>>>>>> toContextText - rtext "+rtext.to_s
            rawtext = rtext.to_s
        end
        rtext = ""
        compstr = rawtext.split("[#Q")
        if compstr.size > 1
            nidx = 0
	    compstr.each do |comp|
                compstr2 = comp.split("Q#]")
                if compstr2.size > 1
                    comp2 = compstr2[1]
                    if nidx < compstr.size - 1
                        if comp2.length > 32
                            rtext = rtext + compstr2[0] + "Q#]" + comp2[0,16] + "..." + comp2[comp2.length - 16,comp2.length - 1] + "[#Q"
                        else
                            rtext = rtext + compstr2[0] + "Q#]" + comp2 + "[#Q"
                        end
                    else
                        # last comp
                        if comp2.length > 16
                            rtext = rtext + compstr2[0] + "Q#]" + comp2[0,16] + "..."
                        else
                            rtext = rtext + compstr2[0] + "Q#]" + comp2
                        end
                    end
                elsif comp.length == 0
                    rtext = rtext + "[#Q"
                elsif nidx < compstr.size - 1
                    if comp.length > 16
                        rtext = rtext + "..." + comp[comp.length - 16,comp.length - 1] + "[#Q"
                    else
                        rtext = rtext + "..." + comp + "[#Q"
                    end
                else
                    rtext = rtext + "..." + comp
                end
                
                nidx = nidx + 1
            end
        else
            rtext = rawtext
        end
        rtext = rtext.gsub("[#Q...Q#]","")
        rtext = rtext.gsub("[#Q","<font color=\"red\"><b><i>")
        rtext = rtext.gsub("Q#]","</i></b></font>")
        return rtext
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by colname
    #------------------------------------------------------------------------------------------------------------------
    def findProjects(exclude_prjids,matchloc,colname,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,colname)
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findProjects sql "+sqlcmd+" qterms "+qterms.to_s
        
	    ret_projs = Array.new
        tmp_prj = Project.find(:all, :conditions=>sqlcmd)
        for prj in tmp_prj
            if !exclude_prjids.include?(prj.id)
                # Pickup project information - creator, create date, etc
                userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                # If a public search - only allow Project.is_public = boolean [f | t]
                if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                    prj.is_public
                    
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    
                    # construct the search hit context text
                    qtext = nil
                    if colname == "title"
                        qtext = toContextText(prj.title.to_s,qterms);
                    elsif colname == "description"
                        qtext = toContextText(prj.description.to_s,qterms);
                    elsif colname == "funding_source"
                        qtext = toContextText(prj.funding_source.to_s,qterms);
                    elsif colname == "notes"
                        qtext = toContextText(prj.notes.to_s,qterms);
                    elsif colname == "author"
                        qtext = toContextText(userinfo.lname.to_s,qterms);
                    end
                    
                    # Pickup the study_id so we can pull associated primary and secondary publications
                    study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                    if !study.nil?
                        prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                        ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo]
                    else
                        ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo]
                    end
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Arms
    #------------------------------------------------------------------------------------------------------------------
    def findProjectsByArms(exclude_prjids,matchloc,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd1 = constructSQL(query_string,"title")
        sqlcmd2 = constructSQL(query_string,"description")
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findProjectsByArms sql1 "+sqlcmd1+" sql2 "+sqlcmd2+" qterms "+qterms.to_s
        sqlcmd = sqlcmd1 + " OR " + sqlcmd2
        
	ret_projs = Array.new
        tmp_prj = Array.new
        tmp_arms = Arm.find(:all, :conditions=>sqlcmd)
        found_prj_ids = Array.new
        for armrec in tmp_arms
            study_id = armrec.study_id
            study = Study.find(:first, :conditions=>["id = ?", study_id])
            prj = Project.find(:first, :conditions=>["id = ?", study.project_id])
            if !exclude_prjids.include?(prj.id) &&
                !found_prj_ids.include?(prj.id)
                # Pickup project information - creator, create date, etc
                userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                # If a public search - only allow Project.is_public = boolean [f | t]
                if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                    prj.is_public
                    
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    
                    # construct the search hit context text
                    qtext = qtext = toContextText(armrec.title.to_s+". "+armrec.description.to_s,qterms);
                    
                    # Pickup the study_id so we can pull associated primary and secondary publications
                    study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                    if !study.nil?
                        prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                        ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo,nil,armrec]
                    else
                        ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo,nil,armrec]
                    end
                    found_prj_ids << prj.id
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by PubMed ID
    #------------------------------------------------------------------------------------------------------------------
    def findProjectsByPubMedID(exclude_prjids,matchloc,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,"pmid")
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findProjectsByPubMedID sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        tmp_prj = Array.new
        tmp_pub = PrimaryPublication.find(:all, :conditions=>sqlcmd)
        found_prj_ids = Array.new
        for pubrec in tmp_pub
            study_id = pubrec.study_id
            study = Study.find(:first, :conditions=>["id = ?", study_id])
            prj = Project.find(:first, :conditions=>["id = ?", study.project_id])
            if !exclude_prjids.include?(prj.id) &&
                !found_prj_ids.include?(prj.id)
                # Pickup project information - creator, create date, etc
                userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                # If a public search - only allow Project.is_public = boolean [f | t]
                if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                    prj.is_public
                    
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    
                    # construct the search hit context text
                    qtext = qtext = toContextText(pubrec.pmid.to_s,qterms);
                    
                    # Pickup the study_id so we can pull associated primary and secondary publications
                    study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                    if !study.nil?
                        prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                        ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo,nil,armrec]
                    else
                        ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo,nil,armrec]
                    end
                    found_prj_ids << prj.id
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by Author
    #------------------------------------------------------------------------------------------------------------------
    def findProjectsByAuthor(exclude_prjids,matchloc,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,"lname")
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findProjectsByAuthor sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        tmp_users = User.find(:all, :conditions=>sqlcmd)
        found_prj_ids = Array.new
        for userinfo in tmp_users
            tmp_prj = Project.find(:all, :conditions=>["creator_id = ?", userinfo.id])
            for prj in tmp_prj
                if !exclude_prjids.include?(prj.id) &&
                    !found_prj_ids.include?(prj.id)
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    # If a public search - only allow Project.is_public = boolean [f | t]
                    if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                        prj.is_public
                        
                        # construct the search hit context text
                        qtext = qtext = toContextText(userinfo.lname.to_s,qterms);
                        
                        # Pickup the study_id so we can pull associated primary and secondary publications
                        study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                        if !study.nil?
                            prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                            ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo]
                        else
                            ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo]
                        end
                        found_prj_ids << prj.id
                    end
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find projects by year
    #------------------------------------------------------------------------------------------------------------------
    def findProjectsByYear(exclude_prjids,matchloc,fromyear,toyear,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        yearval = Integer(toyear) + 1
        sqlcmd = "created_at >= '"+fromyear+"-01-01' AND created_at < '"+yearval.to_s+"-01-01'"
        qterms = [fromyear, toyear]
        puts ">>>>>>>>>>> findProjectsByYear sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        tmp_prj = Project.find(:all, :conditions=>sqlcmd)
        for prj in tmp_prj
            if !exclude_prjids.include?(prj.id)
                # Pickup project information - creator, create date, etc
                userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                # If a public search - only allow Project.is_public = boolean [f | t]
                if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                    prj.is_public
                    
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    
                    # construct the search hit context text
                    qtext = prj.created_at.year.to_s
                    
                    # Pickup the study_id so we can pull associated primary and secondary publications
                    study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                    if !study.nil?
                        prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                        ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo]
                    else
                        ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo]
                    end
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find publications by colname
    #------------------------------------------------------------------------------------------------------------------
    def findPublications(exclude_pubids,matchloc,colname,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,colname)
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findPublications sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        tmp_prj = Array.new
        tmp_pub = PrimaryPublication.find(:all, :conditions=>sqlcmd)
        found_pub_ids = Array.new
        for pub in tmp_pub
            if !exclude_pubids.include?(pub.pmid) &&
                !found_pub_ids.include?(pub.pmid)
                study_id = pub.study_id
                study = Study.find(:first, :conditions=>["id = ?", pub.study_id])
                # Ok - got the Study associated with the publication, now get the Project associated with the Study
                # gather projects that meet public/non-public search criteria into an array
                tmp_prjs = Array.new
                tmp_prj = Project.find(:all, :order=> "created_at", :conditions=>["id = ?", study.project_id])
                for prj in tmp_prj
                    if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                       prj.is_public
                        # If a public search - only allow Project.is_public = boolean [f | t]
                        # Pickup project information - creator, create date, etc
                        userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                        tmp_prjs << [prj,userinfo]
                    end
                end
                # Tag the publication with the first project and carry along the entire list of associated projects
                if tmp_prjs.size() > 0
                    # construct the search hit context text
                    qtext = ""
                    if colname == "pmid"
                        qtext = qtext = toContextText(pub.pmid.to_s,qterms);
                    elsif colname == "title"
                        qtext = qtext = toContextText(pub.title.to_s,qterms);
                    elsif colname == "journal"
                        qtext = qtext = toContextText(pub.journal.to_s,qterms);
                    end
                    
                    ret_projs << [100,tmp_prjs[0][0],qtext,study,[pub],matchloc,tmp_prjs[0][1],tmp_prjs]
                    found_pub_ids << pub.pmid
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find publications by year
    #------------------------------------------------------------------------------------------------------------------
    def findPublicationsByYear(exclude_pubids,matchloc,fromyear,toyear,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        qyear = fromyear
        
        sqlcmd = ""
        qterms = Array.new
        (
            if sqlcmd.length > 0
                sqlcmd = sqlcmd + " OR "
            end
            sqlcmd = sqlcmd + "year = '"+qyear.to_s+"'"
            qterms << qyear.to_s
            qyear = qyear + 1
        ) until qyear > toyear
        puts ">>>>>>>>>>> findPublications sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        tmp_prj = Array.new
        tmp_pub = PrimaryPublication.find(:all, :conditions=>sqlcmd)
        found_pub_ids = Array.new
        for pub in tmp_pub
            if !exclude_pubids.include?(pub.pmid) &&
                !found_pub_ids.include?(pub.pmid)
                study_id = pub.study_id
                study = Study.find(:first, :conditions=>["id = ?", pub.study_id])
                # Ok - got the Study associated with the publication, now get the Project associated with the Study
                # gather projects that meet public/non-public search criteria into an array
                tmp_prjs = Array.new
                tmp_prj = Project.find(:all, :order=> "created_at", :conditions=>["id = ?", study.project_id])
                for prj in tmp_prj
                    if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                       prj.is_public
                        # If a public search - only allow Project.is_public = boolean [f | t]
                        # Pickup project information - creator, create date, etc
                        userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                        tmp_prjs << [prj,userinfo]
                    end
                end
                # Tag the publication with the first project and carry along the entire list of associated projects
                if tmp_prjs.size() > 0
                    # construct the search hit context text
                    qtext = pub.year
                    
                    ret_projs << [100,tmp_prjs[0][0],qtext,study,[pub],matchloc,tmp_prjs[0][1],tmp_prjs]
                    found_pub_ids << pub.pmid
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find adverse events by colname
    #------------------------------------------------------------------------------------------------------------------
    def findAdverseEvents(exclude_prjids,matchloc,colname,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,colname)
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findAdverseEvents sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        found_prj_ids = Array.new
        tmp_adv = AdverseEvents.find(:all, :conditions=>sqlcmd)
        for adv in tmp_adv
            study_id = adv.study_id
            study = Study.find(:first, :conditions=>["id = ?", study_id])
            tmp_prj = Project.find(:all, :order=> "created_at", :conditions=>["id = ?", study.project_id])
            for prj in tmp_prj
                if !exclude_prjids.include?(prj.id) &&
                    !found_prj_ids.include?(prj.id)
                    # Pickup project information - creator, create date, etc
                    userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                    # If a public search - only allow Project.is_public = boolean [f | t]
                    if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                        prj.is_public
                        
                        # Pickup project information - creator, create date, etc
                        userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                        
                        # construct the search hit context text
                        qtext = nil
                        if colname == "title"
                            qtext = toContextText(adv.title.to_s,qterms);
                        elsif colname == "description"
                            qtext = toContextText(adv.description.to_s,qterms);
                        end
                        
                        # Pickup the study_id so we can pull associated primary and secondary publications
                        study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                        if !study.nil?
                            prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                            ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo]
                        else
                            ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo]
                        end
                        
                        # add project id to saved list
                        found_prj_ids << prj.id
                    end
                end
            end
        end
        return ret_projs
    end
    
    #------------------------------------------------------------------------------------------------------------------
    # Find quality dimensions by colname
    #------------------------------------------------------------------------------------------------------------------
    def findQuality(exclude_prjids,matchloc,colname,query_string,is_public)
        user_id = nil;
        if !current_user.nil?
            user_id = current_user.id
        end
        # Construct the SQL command from the query_string entered and database table column name to search on
        sqlcmd = constructSQL(query_string,colname)
        qterms = getQueryTerms(query_string)
        puts ">>>>>>>>>>> findQuality sql "+sqlcmd+" qterms "+qterms.to_s
        
	ret_projs = Array.new
        found_prj_ids = Array.new
        tmp_qual = QualityAspects.find(:all, :conditions=>sqlcmd)
        for qual in tmp_qual
            study_id = qual.study_id
            study = Study.find(:first, :conditions=>["id = ?", study_id])
            if !study.nil?
                puts ">>>>>>> findQuality - study_id = "+study_id.to_s+" has nil study"
                tmp_prj = Project.find(:all, :order=> "created_at", :conditions=>["id = ?", study.project_id])
                for prj in tmp_prj
                    if !exclude_prjids.include?(prj.id) &&
                        !found_prj_ids.include?(prj.id)
                        # Pickup project information - creator, create date, etc
                        userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                        # If a public search - only allow Project.is_public = boolean [f | t]
                        if (!is_public && !user_id.nil? && (user_id == prj.creator_id)) ||
                            prj.is_public
                            
                            # Pickup project information - creator, create date, etc
                            userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                            
                            # construct the search hit context text
                            qtext = toContextText(qual.dimension.to_s,qterms);
                            
                            # Pickup the study_id so we can pull associated primary and secondary publications
                            study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                            if !study.nil?
                                prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                                ret_projs << [100, prj, qtext, study, prim_pub, matchloc, userinfo]
                            else
                                ret_projs << [100, prj, qtext, nil, nil, matchloc, userinfo]
                            end
                            
                            # add project id to saved list
                            found_prj_ids << prj.id
                        end
                    end
                end
            end
        end
        return ret_projs
    end
    
end
