class SearchController < ApplicationController

  # index
  # display search page
  def index
      @page_title = "Search"
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
	
  # results
  # display search results page	
  # TODO - use clearer Hash construct to store and reference components instead of fixed array locations - MK
  # resultslist is a Hash[<project id>] => [<hitscore>, <Projects record>, <search text>, <study>, <Array[Primary publications]>, <match location>, <userinfo>, <Array[Associated projects]>]
	def results
	    query_string = removeInvalidCharacters(params[:user_input])
	    
            # split search text into individual words    
	    @query = query_string.split()
            is_public_search = current_user.nil?
            
            # load search parameters
            @resultslist = Hash.new
            properties = YAML.load_file("properties/search.properties")
            properties['search-groups'].each do |groupid|
                # puts ">>> group id "+groupid[0].to_s
                @resultslist[groupid[0].to_s] = search_database(groupid[0].to_s,@query,is_public_search)
            end
            if !@query.nil?
	        @page_title = "Search Results for \"" + @query.join(" ") + "\""
	    else
	       	@page_title = "Search Results"
	    end
            # Iterate through the results for project and publication level data to support filtering or subselection for display
            @resultslist["projects.categories"] = categorize_projects(@resultslist["projects"])
            @resultslist["publications.categories"] = categorize_publications(@resultslist["publications"])
            # Now save the results in the session
            session[:search_results] = @resultslist
            
            # TODO - these are no longer used, remove them later 1/30/2012 MK
            @proj_array = Array.new;
            @publications_array = Array.new;
            @study_info_array = Array.new;
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

        
  #------------------------------------------------------------------------------------------------------------------------------------------------
  # Search - general search: which assumes only common database table columns are included in the search
  #     each search item is scored based on potential relevance - creating an overall score used to sort best hit
  #     general search inlcudes: Project - title (10), description (5), funding_source (5), creator_id (5)
  #     for each word assess hit score. If there is a hit and also hit the previous word - give bonus points to the hit score
  # method for general search based on the query_array	
  #------------------------------------------------------------------------------------------------------------------------------------------------
	def search_database(groupid,query_array,is_public_search)
          properties = YAML.load_file("properties/search.properties")
          target_ids = Array.new
          properties[groupid+'-general'].each do |targetid|
              target_ids = target_ids + [targetid[0].to_s]
          end
          # puts ">>>> loaded group id "+groupid.to_s+" got targets "+target_ids.to_s

          # searchresults is formatted as a hash[Project.id][Array[<hit score>, <Project>]]
	      searchresults = search_projects(@query,groupid.to_s,target_ids,is_public_search)
          
          # convert searchresults into an array of [<hit score>,<Project>]
          searcharr = Array.new
          searchresults.each_value {|v| searcharr << v}
          # puts "...converted to an array "+searcharr.to_s
          
          # Now sort by hitscore - [0] is the highest, [n] is the lowest
          # Sort the projects into an Array[Project] by the hitscore
          ret_arr = search_bubblesort(searcharr)
          
  	  return ret_arr
	end
        
  #------------------------------------------------------------------------------------------------------------------------------------------------
  # Bubble sort an array of project matches 
  # Float the highest hit score record up to the top
  # projlist is a Array[<hit score>,<Project>]  
  #------------------------------------------------------------------------------------------------------------------------------------------------
        def search_bubblesort(projlist)
            sortedlist = Array.new
            if projlist.length > 0
                while projlist.length > 0 do
                    idx = 0
                    projresult1 = projlist[idx]
                    hitscore = projresult1[0]
                    i = 1
                    while i < projlist.length do
                        projresult2 = projlist[i]
                        hitscore2 = projresult2[0]
                        if hitscore2 > hitscore
                            hitscore = hitscore2
                            projresult1 = projresult2
                            idx = i
                        end
            
                        i = i + 1
                    end
                    # projresult1 has the smallest hit score
                    # save the Project object in the sorted list
                    sortedlist << projresult1
                    
                    # remove projresult1 from the source list
                    projlist.delete_at(idx)
                end
            end
            
            return sortedlist
        end
        
  #------------------------------------------------------------------------------------------------------------------------------------------------
  # Produce context text where q1 was found in tdata   
  #------------------------------------------------------------------------------------------------------------------------------------------------
        def toContextText(tdata,q1)
            if tdata.nil?
                return nil
            end
            
            # Since q1 is mixed caps, need to split using all caps and then re-construct using original fragments to preserve
            # original look of the text. Setup variables to to represent original (raw) and uppercase versions. Use upper case vars
            # to do splits
            rawtext = tdata.to_s
            cq1 = nil
            if !q1.nil?
                cq1 = q1.upcase
            end
            
            # First laydown markers - where to split the text
            ctext = tdata.to_s.upcase
            if !q1.nil?
                ctext = ctext.gsub(cq1, "<b>q1</b>")
            end
            
            # Now condense surrounding text
            compstr = ctext.split("<b>q1</b>")
            rtext = ""
            if compstr.length > 1
                idx = 0
	        compstr.each do |comp|
                    # get the raw fragment - if zero length, set it to "". Ruby takes neg index
                    if comp.length > 0
                        rawcomp = rawtext[0..comp.length - 1]
                    else
                        rawcomp = ""
                    end
                    rawq1 = rawtext[comp.length..(comp.length + q1.length - 1)]
                    # trim the raw text of the fragment + q1 text
                    rawtext = rawtext[(comp.length + q1.length)..rawtext.length - 1]
                    
                    # Just check and condense long components
                    if (idx == compstr.length - 1) && (comp.length > 16)
                        # last component
                        rtext = rtext + rawcomp[0,16] + "..."
                    elsif (rtext.length > 0) && (comp.length > 32)
                        rtext = rtext + rawcomp[0,16]+"..." + rawcomp[rawcomp.length - 16,rawcomp.length - 1]
                    elsif comp.length > 16
                        # first component and long
                        rtext = rtext + "..." + rawcomp[rawcomp.length - 16,rawcomp.length - 1]
                    else
                        rtext = rtext + rawcomp
                    end
                    # If this is not the last component - add the bold q1
                    if idx < compstr.length - 1
                        rtext = rtext + "<font color=\"red\"><b><i>" + rawq1 + "</i></b></font>"
                    end
                    
                    idx = idx + 1
                end
            else
                # No splits found - just return original text
                rtext = rawtext.to_s
            end
            return rtext
        end
        
  #------------------------------------------------------------------------------------------------------------------------------------------------
  # search_for_projects
  # method to search for systematic review projects based on the query_array
  # generalized search method with specified table column names provided in array target_ids 
  # results are ranked ordered - with [0] having the highest hit score, [n] having the lowest   
  #------------------------------------------------------------------------------------------------------------------------------------------------
	def search_projects(query_array,groupid,target_ids,is_public_search)
          properties = YAML.load_file("properties/search.properties")
          puts "... in search_projects"
	  ret_projs = Hash.new
          
          user_id = nil;
          if !current_user.nil?
              user_id = current_user.id
              puts ">>>>>>>>> user id "+user_id.to_s
          end
          
	  target_ids.each do |t|
              # Get the term score - value is formatted as <score>, <desc>
              tv = properties[groupid+"-general"][t].split(", ")
              tscore = tv[0].to_i
              tdesc = tv[1].to_s
              puts ".... looking at term "+t+" value "+tv.to_s+" score "+tscore.to_s
              
              # search for query words in the order "w1 w2 .. w(n)", then "w1 w2 ... w(n-1)" - the longer the sequence, the higher the score
              n_words = query_array.length
              # count characters in array - used to score by word length
              n_chars = 0
              query_array.each do |q|
                  n_chars = n_chars + q.length
              end
              
              qstr = ""
              hitscore = 0
              # until i >= n_words
              i = 0
              puts "... starting string group search i="+i.to_s+" n_words="+n_words.to_s+" and qstr = "+qstr.to_s+" is public "+is_public_search.to_s
              (
                  k = 0
                  while k <= i do
                      j = 0
                      qstr = ""
                      (
                          if j > 0
                              qstr = qstr + " "
                          end
                          qstr = qstr + query_array[k + j]
                          j = j + 1
                      ) until j >= n_words - i
    	              q1 = "% "+qstr.to_s+"%"
    	              q2 = "%"+qstr.to_s+" %"
                      puts "... sql ("+t.to_s+" LIKE '"+q1.to_s+"' OR "+t.to_s+" LIKE '"+q2.to_s+"')"
                      tmp_proj = Array.new
                      if groupid == "projects"
                          puts "...searching Projects"
    	                  tmp_prj = Project.find(:all, :conditions=>["UPPER("+t.to_s+") LIKE ? OR UPPER("+t.to_s+") LIKE ?", q1.upcase,q2.upcase])
    		          for prj in tmp_prj
                              # Pickup project information - creator, create date, etc
        	                  userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                              # If a public search - only allow Project.is_public = boolean [f | t]
                              puts ">>>---------------------------------------------------------------------------------------------"
                              puts ">>> got prj prior to public screen "+prj.title+" is_public "+prj.is_public.to_s+" is_public_search "+is_public_search.to_s
                              if (!is_public_search && !user_id.nil? && (user_id == prj.creator_id)) ||
                                 prj.is_public
                                  # construct the search hit context text
                                  qtext = nil;
                                  if t.to_s == "title"
                                      qtext = toContextText(prj.title.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  elsif t.to_s == "description"
                                      qtext = toContextText(prj.description.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  elsif t.to_s == "funding_source"
                                      qtext = toContextText(prj.funding_source.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  elsif t.to_s == "notes"
                                      qtext = toContextText(prj.notes.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  end
                                  puts "::::::::::::::: qtext "+qtext
                                  # Pickup the study_id so we can pull associated primary and secondary publications
        	                      study = Study.find(:first, :conditions=>["project_id = ?", prj.id])
                                  if !study.nil?
        	                          prim_pub = PrimaryPublication.find(:all, :order=> "year", :conditions=>["study_id = ?", study.id])
                                      tmp_proj << [prj,qtext,study,prim_pub,tdesc,userinfo]
                                  else
                                      tmp_proj << [prj,qtext,nil,nil,tdesc,userinfo]
                                  end
                              end
                          end
                      elsif groupid == "publications"
                          puts "...searching Publications"
    		              tmp_pub = PrimaryPublication.find(:all,:conditions=>["UPPER("+t.to_s+") LIKE ? OR UPPER("+t.to_s+") LIKE ?", q1.upcase,q2.upcase])
                          # Now iterate through all the publication hits to pull the associated Project and save the project record
                          # Publication.study_id is linked to a Study, use the Study.project_id then to get the Project record
                          for pub in tmp_pub
    		              if !pub.study_id.nil? && pub.study_id != ""
                                  # construct the search hit context text
                                  qtext = nil;
                                  if t.to_s == "title"
                                      qtext = toContextText(pub.title.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  elsif t.to_s == "author"
                                      qtext = toContextText(pub.author.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  elsif t.to_s == "pmid"
                                      qtext = toContextText(pub.pmid.to_s," "+qstr.to_s);
                                      qtext = toContextText(qtext,qstr.to_s+" ");
                                  end
                                  puts "::::::::::::::: qtext "+qtext
                                  
    	                          study = Study.find(:first, :conditions=>["id = ?", pub.study_id])
                                  # Ok - got the Study associated with the publication, now get the Project associated with the Study
                                  # gather projects that meet public/non-public search criteria into an array
                                  tmp_prjs = Array.new
    	                          tmp_prj = Project.find(:all, :order=> "created_at", :conditions=>["id = ?", study.project_id])
    		                  for prj in tmp_prj
                                      if (!is_public_search && !user_id.nil? && (user_id == prj.creator_id)) ||
                                         prj.is_public
                                          # If a public search - only allow Project.is_public = boolean [f | t]
                                          # Pickup project information - creator, create date, etc
        	                          userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                                          tmp_prjs << [prj,userinfo]
                                      end
                                  end
                                  # Tag the publication with the first project and carry along the entire list of associated projects
                                  if tmp_prjs.size() > 0
                                      tmp_proj << [tmp_prjs[0][0],qtext,study,[pub],tdesc,tmp_prjs[0][1],tmp_prjs]
                                  end
    			      end
                          end
                      elsif groupid == "studies - no longer used, title field removed"
                          puts "...searching Studies"
    		              tmp_study = Study.find(:all,:conditions=>["UPPER("+t.to_s+") LIKE ? OR UPPER("+t.to_s+") LIKE ?", q1.upcase,q2.upcase])
                          # for each study with a hit - pull the associated project and array of publications
                          for study in tmp_study
                              # construct the search hit context text
                              qtext = nil;
                              if t.to_s == "title"
                                  qtext = toContextText(study.title.to_s," "+qstr.to_s);
                                  qtext = toContextText(qtext,qstr.to_s+" ");
                              end
                                  
    	                      prj = Project.find(:first, :conditions=>["id = ?", study.project_id])
                              # If a public search - only allow Project.is_public = boolean [f | t]
                              if (!is_public_search && !user_id.nil? && (user_id == prj.creator_id)) ||
                                 prj.is_public
                                  # Pickup project information - creator, create date, etc
        	                  userinfo = User.find(:first, :conditions=>["id = ?", prj.creator_id])
                                  # Pickup associated publications for this study
    	                          tmp_pub = PrimaryPublication.find(:all, :conditions=>["study_id = ?", study.id])
                                  tmp_proj << [prj,qtext,study,tmp_pub,tdesc,userinfo,nil]
                              end
                          end
                      else
                          # search group type not handled
                      end
                      
                      puts "found projects "+tmp_proj.to_s+" for qstr "+qstr.to_s+" on term "+t+" i "+i.to_s+" of n_words "+n_words.to_s
                      # iterate through all the projects found and tag it with a hit score if it was not already scored
    	              for data in tmp_proj
                          proj = data[0]
                          qtext = data[1]
                          study = data[2]
                          tmp_pub = data[3]
                          matchloc = data[4]
                          userinfo = data[5]
                          # Check to see if there is a list of associated projects
                          assocprjs = nil;
                          if data.length > 6
                              assocprjs = data[6]
                          end
                          
                          # Choose best match score by number of words and total characters matched, weight it by tscore
                          hitscore = (100 * tscore * (n_words - i)) / (100 * n_words)
                          charscore = (100 * tscore * qstr.length) / (100 * n_chars)
                          # See if matched on big words versus a bunch of small words
                          if charscore >= hitscore
                              hitscore = charscore
                          end
                          puts "checking if "+proj.id.to_s+" is already in list "+ret_projs.to_s+" hitscore = "+hitscore.to_s
                          if ret_projs[proj.id] == nil
                              ret_projs[proj.id] = [hitscore, proj, qtext, study, tmp_pub, matchloc, userinfo, assocprjs]
                              puts "... scoring hit on id "+proj.id.to_s+" n_words = "+n_words.to_s+" i "+i.to_s+" tscore "+tscore.to_s+" --> "+hitscore.to_s 
                          elsif groupid == "projects"
                              # project_id was already found - just update the score if a better match was found
                              # covers situation where a longer match sequence was found in the description vs title
                              # Check to see if this hit has a higher score
                              prev_entry = ret_projs[proj.id]
                              prevscore = prev_entry[0]
                              if prevscore < hitscore
                                  prev_entry[0] = hitscore
                                  prev_entry[2] = qtext
                              end
                          else
                              # Just add entry
                              ret_projs[proj.id] = [hitscore, proj, qtext, study, tmp_pub, matchloc, userinfo, assocprjs]
                          end
    	              end
                  
                      k = k + 1
                  end 
                  
                  # go to the next group of words
                  i = i + 1
              ) until i >= n_words     
	  end
          #puts "*********** results of search "+ret_projs.to_s
	  return ret_projs
	end
	
  #--------------------------------------------------------------------------------------------------------------------------------
  # method to search for projecs based on the query_array
  #--------------------------------------------------------------------------------------------------------------------------------
	def search_for_projects(query_array)
      siteproperties = Guiproperties.new
	  ret_arr = Array.new
		query_array.each do |q|
			q = "%"+q.to_s+"%"
            if siteproperties.isMySQL()
			    tmp_proj = Project.find(:all, :conditions=>["(UPPER(title) LIKE ? OR UPPER(description) LIKE ?) AND is_public = ?", q.upcase, q.upcase, 1])
            else
			    tmp_proj = Project.find(:all, :conditions=>["(UPPER(title) LIKE ? OR UPPER(description) LIKE ?) AND is_public = ?", q.upcase, q.upcase, 't'])
            end
			for proj in tmp_proj
				ret_arr << proj
			end
		end
		ret_arr = remove_dups(ret_arr)
		return ret_arr
	end
	
  #--------------------------------------------------------------------------------------------------------------------------------
  # method to search for study publications based on the query_array
  #--------------------------------------------------------------------------------------------------------------------------------
	def search_for_publications(query_array)
        siteproperties = Guiproperties.new
		ret_arr = Array.new
		query_array.each do |q|
			q = "%"+q.to_s+"%"
            if siteproperties.isMySQL()
			    tmp_pub = PrimaryPublication.find(:all,:conditions=>["is_public = 1 AND (UPPER(title) LIKE ? OR UPPER(author) LIKE ? or UPPER(country) LIKE ? or year LIKE ?)",q.upcase,q.upcase,q.upcase,q])
            else
			    tmp_pub = PrimaryPublication.find(:all,:conditions=>["is_public = 't' AND (UPPER(title) LIKE ? OR UPPER(author) LIKE ? or UPPER(country) LIKE ? or year LIKE ?)",q.upcase,q.upcase,q.upcase,q])
            end
			for pub in tmp_pub
				if !pub.study_id.nil? && pub.study_id != ""
					study = Study.find(pub.study_id, :select=>["id","project_id"])
					project = Project.find(study.project_id, :select=>["id", "is_public"])
					if project.is_public
						ret_arr << pub
					end
				end
			end
		end
		ret_arr = remove_dups(ret_arr)
	  return ret_arr
	end
	
  #--------------------------------------------------------------------------------------------------------------------------------
  # get_study_info
  # return the project_id and study_type fields for the studies linked to the primary publications
  #--------------------------------------------------------------------------------------------------------------------------------
	def get_study_info(publications)
	  ret_arr = Array.new
		publications.each do |pub|
		  if !pub.study_id.nil?
				begin
					tmp_study = Study.find(pub.study_id)
					ret_arr << [tmp_study.study_type, tmp_study.project_id]
				rescue
				end
		  end
		end
		return ret_arr
	end
	
  #--------------------------------------------------------------------------------------------------------------------------------
  # remove_dups
  # return only unique projects in the projects list
  #--------------------------------------------------------------------------------------------------------------------------------
	def remove_dups(projects)
		 projects.uniq #=> projects
		 return projects.uniq
	end
end
