###############################################################################
# This class contains code for exporting various parts of a systematic review #
# to Microsoft Excel format. 																									#
###############################################################################

class ExcelExport
	
	# export all information related to a systematic review project
	# a file for project information (contains key questions, study listing, extraction form listing)
	# a file for extraction forms (contains 1 per tab)
	# a file for studies/extracted data (extracted data?)
	def self.project_to_xls proj_id, user 
		puts "ENTERED THE PROJECT TO XLS FUNCTION\n\n"
		proj = Project.find(proj_id)
		files = Array.new
		doc = Spreadsheet::Workbook.new # create the workbook
		
		# EXCEL FORMATTING 
		section_title = Spreadsheet::Format.new(:weight => :bold, :size => 14) 
		bold = Spreadsheet::Format.new(:weight=>:bold,:align=>'center',:vertical_align=>'top')
		bold_centered = Spreadsheet::Format.new(:weight => :bold, :align=>"center", :text_wrap=>true) 
		centered = Spreadsheet::Format.new(:align=>"center", :text_wrap=>true) 
		bold_merged = Spreadsheet::Format.new(:weight=>:bold, :align=>'merge', :text_wrap=>true)
		normal_wrap = Spreadsheet::Format.new(:text_wrap => true,:vertical_align=>"top")
		row_data = Spreadsheet::Format.new(:text_wrap => true,:align=>"center",:vertical_align=>"top")
		black_box = Spreadsheet::Format.new(:color=>"gray",:pattern_fg_color=>"gray",:pattern=>1)
		formats = {'section_title'=>section_title,'bold'=>bold,'bold_centered'=>bold_centered,'centered'=>centered,
		          'bold_merged'=>bold_merged,'normal_wrap'=>normal_wrap,'row_data'=>row_data,'black_box'=>black_box}
		doc.add_format(section_title)
		doc.add_format(bold)
		doc.add_format(bold_centered)
		doc.add_format(centered)
		doc.add_format(normal_wrap)
		doc.add_format(row_data)
		doc.add_format(black_box)
		
		## CREATE A WORKBOOK FOR GENERAL PROJECT INFO
		#self.get_project_info(doc,proj,formats)
		#self.get_project_users(doc,proj,formats)
		
		#file1 = "#{user.login.to_s}_project_overview.xls"
		## WRITE THE OVERVIEW DOCUMENT AND SAVE THE FILENAME
		#doc.write "exports/#{file1}"
		#files << file1 
		
		# NOW BEGIN EXPORTING EACH EXTRACTION FORM
		extraction_forms = proj.extraction_forms
		unless extraction_forms.empty?
			i = 1
			
		# UNCOMMENT THIS FOR ZIPPED VERSION
			#extraction_forms.each do |ef|  
				ef = extraction_forms.first	
				#doc = Spreadsheet::Workbook.new # reset the workbook
				#doc.add_format(section_title)
				#doc.add_format(bold)
				#doc.add_format(bold_centered)
				#doc.add_format(normal_wrap)
				#doc.add_format(row_data)
				begin
					# GATHER UP PROJECT INFORMATION THAT WILL BE SHARED ACROSS THE MANY TABS
					# CURRENTLY, THESE SHARED ITEMS ARE PASSED TO EACH FUNCTION FOR EXPORTING:
					# studies, creators, publications, arms, outcomes
					#studies = Study.where(:id=>study_ids).order("id ASC").select(["id","creator_id","created_at"]) # have study objects available for function calls
					studies = Study.where(:project_id=>proj_id).order("id ASC").select(["id","creator_id","created_at"])
					study_ids = studies.collect{|x| x.id}
					arms = Arm.where(:study_id=>study_ids, :extraction_form_id=>ef.id)
					outcomes = Outcome.where(:study_id=>study_ids, :extraction_form_id=>ef.id)
					user_ids = studies.collect{|x| x.creator_id}
					creators = User.where(:id=>user_ids.uniq)
					publications = PrimaryPublication.where(:study_id=>study_ids)
					
					#puts "STUDIES IS #{study_ids}\n\n"
					puts "------EXPORTING -----\n\nTHERE ARE #{study_ids.length} study IDs and #{studies.length} studies were found\n\n\n"
				rescue Exception => e 
					puts "ERROR: #{e.message}"
				end
				# ADDING THIS HERE IN ORDER TO OUTPUT ONLY ONE FILE
				# REMOVE THIS SECTION AND UNCOMMENT THE TOP PORTION FOR THE ZIPPED VERSION
				self.get_project_info(doc,proj,formats)
				self.get_project_users(doc,proj,formats)
				
				unless studies.empty?
					sections = ExtractionFormSection.where(:extraction_form_id=>ef.id, :included=>true).select(:section_name)
					sections = sections.collect{|x| x.section_name}
					unless sections.empty?
					  # ---------- arms -------------
					  if sections.include?('arms')
					  	begin
					  		puts "STARTING ARMS FOR THE #{studies.length} STUDIES"
					   		self.get_project_arms(doc,ef,studies,creators,publications,arms,formats)
					   	rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting arms.\n\n"
					  end
					  # ---------- arm details -------------
					  if sections.include?('arm_details')
					  	begin
					  		self.get_question_and_answers_by_arm(doc,ef,studies,creators,publications,arms,formats,'arm_detail','Arm Details')
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting arm details.\n\n"
					  end
					  # ---------- outcomes -------------
					  if sections.include?('outcomes')
					  	begin
					  		self.get_project_outcomes(doc,ef,studies,creators,publications,outcomes,formats)
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting outcomes.\n\n"
					  end
					  # ---------- outcome details -------------
					  if sections.include?('outcome_details')
					  	begin
					  		self.get_question_and_answers(doc, ef, studies, creators, publications, formats, 'outcome_detail', 'Outcome Details')
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting outcome details"
					  end
					  # ---------- design details -------------
					  if sections.include?('design')
					  	begin
					  		self.get_question_and_answers(doc, ef, studies, creators, publications, formats,"design_detail","Design")
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting design details.\n\n"
					  end
					  # ---------- baseline characteristics -------------
					  if sections.include?('baselines')
					  	begin
					  		self.get_question_and_answers_by_arm(doc, ef, studies, creators, publications, arms, formats,"baseline_characteristic","Baselines",{"include_total"=>true})
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting baseline characteristics\n\n"
					  end
					   # ---------- adverse events -------------
					  if sections.include?('adverse')
					  	begin
					  		self.get_adverse_event_data(doc, ef, studies, creators, publications, arms, formats)
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting Adverse Event Data.\n\n"
					  end	
					  # ---------- quality -------------
					  if sections.include?('quality')
					  	begin
					  		self.get_quality_data(doc, ef, studies, creators, publications, formats)
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting quality data.\n\n"
					  end
					  # ---------- results -------------	  
					  if sections.include?('results')
					  	begin
					  		self.get_results_data(doc, proj, ef, studies, creators, publications, arms, outcomes, formats)
					    rescue Exception => e
					   		puts "AN ERROR OCCURED: #{e.message}, #{e.backtrace}"
					   	end
					  	puts "Getting results entries.\n\n"
					  end
					end
				end
				#tmpFilename = "#{user.login.to_s}_project_data_ef_#{i.to_s}.xls"
				#doc.write "exports/#{tmpFilename}"
				#files << tmpFilename
				#i+=1
			#UNCOMMENT THIS IN ZIPPED VERSION
			#end
		end # end unless extraction_forms.empty?
		blob = StringIO.new("")
		doc.write blob
		#return files
		return blob.string
	end
	
	private
	
	#--------------------------------------------------------------------------
	# GET_PROJECT_INFO
	# GATHER THE BASIC PROJECT MATERIAL TO THE doc WORKBOOK
	#--------------------------------------------------------------------------
	def self.get_project_info(doc,project,formats)
		# formatting
	  info = doc.create_worksheet :name => "General Info"
	  
	  ## title of sheet
	  #info.row(0).concat ["General Project Information"]
	  #info.row(0).set_format(0,formats['section_title'])
	  
	  # creator
	  user = User.find(project.creator_id)
	  user_info = user.to_string
	  info.row(0).concat ["Creator", user_info]
	  info.row(1).concat ["Organization",user.organization]
	  
	  # basic info
	  info.row(2).concat ["Title", project.title]
	  info.row(3).concat ["Description", project.description.to_s]
	  info.row(4).concat ["Funding Agency", project.funding_source.to_s]
	  info.row(5).concat ["Notes", project.notes.to_s]
	  	  	  
	  # key questions
	  current_row = 6
	  kqs = project.key_questions.order("question_number ASC")
	  unless kqs.empty?
	  	for i in 1..kqs.length
	  		kqnum = "KQ"+i.to_s
	  	  info.row(current_row).concat [kqnum, kqs[i-1].question.to_s]
	  	  current_row += 1
	  	end
	  else
	  	info.row(current_row).concat ["Key Questions", "There are no key questions associated with this project."]
	  end
	  info.column(0).width=20
	  info.column(1).width=100
	  
	  # set formats for all rows
	  for i in 1..info.last_row_index do
	  	# make first column bold
	  	info.row(i).set_format(0,formats['bold'])
	  	# make second column wrap
	  	info.row(i).set_format(1,formats['normal_wrap'])
	  	# give the rows a maximum height
	  	info.row(i).height = 40
	  end
	end
	#-------------- END get_project_info --------------------#
	
	#--------------------------------------------------------------------------
	# GET_PROJECT_USERS
	# GATHERS THE LIST OF TEAM MEMBERS ASSOCIATED WITH THE PROJECT AND PRINTS THEIR
	# NAMES AND EMAIL ADDRESSES
	#--------------------------------------------------------------------------
	def self.get_project_users(doc,project,formats)
		utab = doc.create_worksheet :name => 'Team Members'
	  
	  #utab.row(0).concat ['Project Team Members']
	  #utab.row(0).set_format(0,formats['section_title'])
	  
	  team_members = UserProjectRole.where(:project_id=>project.id).order("role DESC")
	  unless team_members.empty?
	  	# user headings
	  	utab.row(0).concat ['User Role','Name','Email']
	  	
	  	utab.row(0).set_format(0,formats['bold_centered'])
	  	utab.row(0).set_format(1,formats['bold_centered'])
	  	utab.row(0).set_format(2,formats['bold_centered'])
	  	
	  	# list the users
	  	current_row=1
	  	team_members.each do |member|
	  		userObj = User.find(member.user_id)
	  		utab.row(current_row).concat [member.role, userObj.to_string,  userObj.email.to_s]
	  		utab.row(current_row).set_format(0,formats['row_data'])
	  		utab.row(current_row).set_format(1,formats['row_data'])
	  		utab.row(current_row).set_format(2,formats['row_data'])
	  		utab.row(current_row).height = 30
	  		current_row += 1
	  	end
	  	utab.column(0).width=20
	  	utab.column(1).width=30
	  	utab.column(2).width=40
	  else
	  	utab.row(0).concat ['There are no users associated with this project.']
	  end
	end
	#-------------- END get_project_users --------------------#
	#--------------------------------------------------------------------------
	# GET_PROJECT_ARMS
	# ADD A WORKSHEET CONTAINING A TABLE OF ARM ASSIGNMENTS FOR THE PROJECT
	#--------------------------------------------------------------------------
	def self.get_project_arms(doc,ef,studies,creators,publications,arms,formats)
		armsTab = doc.create_worksheet :name => "Study Arms"
		
		#armsTab.row(0).concat ['Study Arms']
		#armsTab.row(0).set_format(0, formats['section_title'])	
		col_widths = [19,15,9,26,21]
		# get the max number of arms we need to list
		max_count = 0
		studies.collect{|s| s.id}.each do |sid|
			#count = Arm.count(:conditions=>["study_id=?",sid])
			count = arms.select{|x| x.study_id == sid}.length
			max_count = count if count > max_count
		end
		
		['Creator','Date','PMID','Title (Year)','Author'].each_with_index do |header, col|
			armsTab.row(0).concat [header]
			armsTab.row(0).set_format(col,formats['bold_centered']) 
			armsTab.column(col).width = col_widths[col]
		end
		col_offset = 5
		for i in 0..max_count - 1 
			armsTab[0,i+col_offset] = "Arm #{i+1}"
			armsTab.row(0).set_format(i+col_offset, formats['bold_centered'])
			armsTab.column(i+col_offset).width = 19
		end
		studies.each_with_index do |s, index|
			# GET PRIMARY PUBLICATION
			prim = publications.find{|p| p.study_id == s.id}
			creator = creators.find{|x| x.id == s.creator_id}
			creator = creator.nil? ? "Undefined" : creator.login

			title = "-- not defined --"
			pmid = "---"
			author = "---"
			unless prim.nil?
				title = "#{prim.title} (#{prim.year.to_s})"
				pmid = prim.pmid.to_s
				author = prim.author.to_s
			end
			study_arms = arms.select{|a| a.study_id == s.id}
			arm_titles = study_arms.collect{|a| a.title}
			#arms = s.arms.collect{|a| a.title}
			armsTab.row(index+1).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, title, author]
			col = 5
			arm_titles.each do |arm|
				armsTab.row(index+1).concat [arm]
			end
			for i in 0..col_offset - 1
				armsTab.row(index + 1).set_format(i,formats['normal_wrap'])
			end
			for i in col_offset..armsTab.column_count - 1
				armsTab.row(index + 1).set_format(i,formats['row_data'])
			end
			armsTab.row(index+1).height=40
		end
	end
	#-------------- END ARMS TABS --------------------#
	
	
	#----------------------------------------------------#
	# GET_PROJECT_OUTCOMES
	# RETURN OUTCOMES ASSOCIATED WITH THE PROJECT. ONE TAB WILL
	# SHOW OUTCOME ASSIGNMENTS WHILE ANOTHER WILL PROVIDE DETAILS
	# REGARDING EACH OUTCOME
	#----------------------------------------------------#
	def self.get_project_outcomes(doc, ef, studies, creators, publications, outcomes, formats)
		# CREATE THE OUTCOMES WORKSHEET
		ocTab = doc.create_worksheet :name => "Outcomes"
		#ocTab.row(0).concat ['Outcomes Assigned']
		#ocTab.row(0).set_format(0,formats['section_title'])
		
		col_widths = [19,15,9,26,21]

		# CREATE THE OUTCOME INFO WORKSHEET
		ocInfoTab = doc.create_worksheet :name => "Outcome Info"
		#ocInfoTab.row(0).concat ['Outcome Info']
		#ocInfoTab.row(0).set_format(0,formats['section_title'])
	
		# determine the largest number of outcomes in the project
		max_count = 0
		studies.collect{|s| s.id}.each do |sid|
			#count = Outcome.count(:conditions=>["study_id=?",sid])
			count = outcomes.select{|o| o.study_id == sid}.length
			max_count = count if max_count < count
		end

		#### CREATE THE FIRST ROW ####
		[ocTab,ocInfoTab].each do |tab|
			['Creator','Date','PMID','Title (Year)','Author'].each_with_index do |header,col|
				tab[0,col] = header
				tab.row(0).set_format(col,formats['bold_centered'])
				tab.column(col).width = col_widths[col]
			end
		end
		## Include the Arm 1 .. Arm N for the ocTab
		col_offset = 5

		for i in 0..max_count - 1 
			ocTab[0,col_offset+i] = "Outcome #{i+1}"
			ocTab.row(0).set_format(col_offset+i,formats['bold_centered'])
			ocTab.column(i+col_offset).width = 19
		end
		## Include the Column Headers for the ocInfoTab
		['Outcome','Description','Unit(s)','Timepoint(s)','Subgroup(s)','Primary?','Type','Notes'].each_with_index do |head,col|
			ocInfoTab.row(0).concat [head]
			ocInfoTab.row(0).set_format(col_offset + col, formats['bold_centered'])
			ocInfoTab.column(col_offset + col).width = 19
		end

		ocInfoTab_row = 1
		#### LOOP THROUGH STUDIES, PRINT INFO AND OUTCOMES ###
		studies.each_with_index do |s, row|
			## Get Primary Publication
			prim = publications.find{|p| p.study_id == s.id}
			creator = creators.find{|c| c.id == s.creator_id}
			creator = creator.nil? ? "Undefined" : creator.login

			title = "-- not defined --"
			pmid = "---"
			author = "---"
			unless prim.nil?
				title = "#{prim.title} (#{prim.year.to_s})"
				pmid = prim.pmid.to_s
				author = prim.author.to_s
			end
			## Print the study information
			ocTab.row(row+1).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, title, author]

			## Get Study Outcomes
			#ocs = Outcome.where(:study_id=>s.id, :extraction_form_id=>ef.id)
			ocs = outcomes.select{|o| o.study_id == s.id}
			ocs.each do |oc|
				# simply write the outcomes in the ocTab table
				ocTab.row(row+1).concat ["#{oc.title}"]

				# in the outcome info table, we need to include everything
				ocInfoTab.row(ocInfoTab_row).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, title, author]
				tps = oc.outcome_timepoints
				tps = tps.collect{|x| x.id}
				tpNames = []
				tps.each do |tp|
					tpNames << OutcomeTimepoint.get_title(tp)
				end
				sgs = oc.outcome_subgroups.collect{|x| x.title + (x.description.blank? ? "" : " (#{x.description})")}
				sgs = sgs.join(", ")
				[oc.title, oc.description, oc.units, tpNames.join(", "), sgs, oc.is_primary? ? "Yes" : "No", oc.outcome_type, oc.notes].each_with_index do |datapoint, col|
					ocInfoTab.row(ocInfoTab_row).concat [datapoint]
					ocInfoTab.row(ocInfoTab_row).set_format(col + col_offset, formats['row_data'])
				end
				for i in 0..col_offset - 1
					ocInfoTab.row(ocInfoTab_row).set_format(i,formats["normal_wrap"])
				end
				ocInfoTab.row(ocInfoTab_row).height=40
				ocInfoTab_row += 1
			end
			ocTab.row(row+1).height=40
			# formatting
			for i in 0..col_offset - 1
				ocTab.row(row+1).set_format(i,formats["normal_wrap"])
			end
			for i in 0..ocTab.column_count - 1
				ocTab.row(row+1).set_format(i,formats["row_data"])
			end
		end
	end # end get_project_outcomes

	#-------------- END OUTCOMES TABS --------------------#
	#----------------------------------------------------#
	
	# GET_QUESTION_AND_ANSWERS
	# EXPORT QUESTION-BUILDER STYLE SECTIONS
	#
	# @params doc         - the excel document to add this tab to [spreadsheet object]
	# @params ef		  - the extraction form to extraction data for
	# @params studies     - an array of studies needing export  [array]
	# @params formats     - the array of spreadsheet formats to be used [array]
	# @params db_model    - the base database table, e.g. design_detail, baseline_characteristic [string]
	# @params tab_title   - the title of the tab to create [string]
	# --- options hash ---
	# @params by_arm      - should the questions be formatted by arm? [boolean]
	# @params arm_total   - should a 'total' arm be included? [boolean]
	# @params by_outcome  - should the questions be formatted by outcome? [boolean]
	# @params outcome_total - should a 'total' outcome be included? [boolean]
	#----------------------------------------------------#
	def self.get_question_and_answers(doc, ef, studies, creators, publications, formats, model_name, tab_title )
		# Generate the name of the model form the model_name parameter
		db_model = model_name.split("_").map{|m| m.capitalize}.join("")

		# get a list of the study ids being used for future reference
		study_ids = studies.collect{|x| x.id}
		col_widths = [19,15,9,26,21]
		
		# CREATE THE WORKSHEET
		tabCount = 1
		qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
		current_col = 5

		# GET ALL OF THE QUESTIONS 
		questions = eval(db_model).where(:extraction_form_id=>ef.id).order("question_number ASC")
		unless questions.empty?
		    
			# LOOP THROUGH THE DESIGN DETAILS
		    questions.each do |ques|

		    	# PREPARE TO STORE MATRIX INFORMATION WHEN NECESSARY
				matrix_rows = []
				matrix_cols = []
				matrix_other = []
				num_columns_needed = 0

			  	# GET ANY AVAILABLE SUBQUESTION
			  	sq = ques.get_subquestion
			  	sq = sq.nil? ? "" : sq.empty? ? "" : "...#{sq}"
				
				# IF IT'S A MATRIX QUESTION, SET UP THE MERGED HEADER AND COLUMN/ROW COMBINATIONS
				if ques.field_type.match("matrix")
					matrix_rows = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number > ?",ques.id, 0], :order=>"row_number ASC")
  					matrix_cols = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND column_number > ?",ques.id, 0], :order=>"column_number ASC")
  					matrix_other = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number < ?",ques.id, 0], :order=>"row_number DESC")
  					if ques.field_type == 'matrix_select'
	  					num_columns_needed = matrix_cols.length * matrix_rows.length + matrix_other.length
	  					
	  					# IF WE'RE RUNNING OUT OF SPACE IN THIS TAB, CREATE ANOTHER ONE
	  					if current_col + num_columns_needed > 250
	  						tabCount += 1
	  						qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
	  						current_col = 5
	  					end

	  					qTab[0,current_col] = "#{ques.question}"
	  					matrix_rows.each_with_index do |r,rowIndex|
	  						matrix_cols.each_with_index do |c,colIndex|
	  							qTab.row(0).set_format(current_col + (rowIndex * matrix_cols.length) + colIndex, formats['bold_merged'])
	  							col_row_combo = "row: #{r.option_text} // col: #{c.option_text}"
	  							qTab[1,current_col + (rowIndex * matrix_cols.length) + colIndex] = col_row_combo
	  							qTab.column(current_col + (rowIndex * matrix_cols.length) + colIndex).width = 15
	  							qTab.row(1).set_format(current_col + (rowIndex * matrix_cols.length) + colIndex, formats['centered'])
	  						end
	  					end
	  					matrix_other.each_with_index do |mo,moIndex|
	  						qTab.row(0).set_format(current_col + num_columns_needed - 1, formats['bold_merged'])
	  						qTab[1,current_col + num_columns_needed - 1] = mo.option_text
	  						qTab.row(1).set_format(current_col + num_columns_needed - 1, formats['centered'])
	  					end
	  				else
	  					num_columns_needed = matrix_rows.length + matrix_other.length
	  					# IF WE'RE RUNNING OUT OF SPACE IN THIS TAB, CREATE ANOTHER ONE
	  					if current_col + num_columns_needed > 250
	  						tabCount += 1
	  						qTab = create_new_tab(doc, tab_title, tabCount, studies, formats)
	  						current_col = 5
	  					end
	  					qTab[0,current_col] = "#{ques.question}"
	  					matrix_rows.each_with_index do |r,rowIndex|
	  						qTab.row(0).set_format(current_col + rowIndex, formats['bold_merged'])
	  						qTab[1,current_col + rowIndex] = r.option_text
	  						qTab.row(1).set_format(current_col + rowIndex, formats['centered'])
	  					end
	  					unless matrix_other.empty?
	  						qTab.row(0).set_format(current_col + num_columns_needed - 1, formats['bold_merged'])
	  						qTab[1,current_col + num_columns_needed - 1] = matrix_other.first.option_text
	  						qTab.row(1).set_format(current_col + num_columns_needed - 1, formats['centered'])
	  					end
	  				end

  				# IF IT'S NOT A MATRIX QUESTION, PUT THE SUBQUESTION ON THE NEXT ROW AND SET FORMATTING
				else
					# IF WE'RE RUNNING OUT OF SPACE IN THIS TAB, CREATE ANOTHER ONE
  					if current_col + 1 > 250
  						tabCount += 1
  						qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
  						current_col = 5
	  				end
					qTab[0,current_col] = "#{ques.question}"
					qTab[1,current_col] = "#{sq}"
					qTab.row(0).set_format(current_col,formats['bold_centered'])
					qTab.row(1).set_format(current_col,formats['centered'])
					qTab.column(current_col).width = 19

				end
				
				# GET ANSWERS FOR ALL STUDIES
				datapoints = eval("#{db_model}DataPoint").find(:all, :conditions=>["#{model_name}_field_id=? AND study_id IN (?)",ques.id, study_ids])
				if ques.field_type.match("matrix")
					unless datapoints.empty?
						datapoints.each do |dp|
							row_index = study_ids.index(dp.study_id) + 2
							# dp.column_field_id is zero when the quesiton is not a matrix_select type
							# if dp.column_field_id == 0
							unless ques.field_type == 'matrix_select'
								rowObj = matrix_rows.find{|mr| mr.id == dp.row_field_id}
								rnum = matrix_rows.index(rowObj)
								colObj = matrix_cols.find{|mc| mc.option_text == dp.value}
								cnum = matrix_cols.index(colObj)
								#puts "\n\nTHE ROW NUMBER IS #{rnum} AND THE COLUMN NUMBER IS #{cnum}\n\n"
								unless rnum.nil? || cnum.nil?
									if qTab[row_index,current_col + rnum].nil?
										qTab[row_index,current_col + rnum] = dp.value.to_s
									else
										qTab[row_index,current_col + rnum] = "#{qTab[row_index,current_col + rnum]} // #{dp.value.to_s}"
									end
								else
									qTab[row_index, current_col + num_columns_needed - 1] = dp.value.to_s
								end
							else
								colObj = matrix_cols.find{|mc| mc.id == dp.column_field_id}
								cnum = matrix_cols.index(colObj)
								rowObj = matrix_rows.find{|mr| mr.id == dp.row_field_id}
								rnum = matrix_rows.index(rowObj)
								#puts "\n\nTHE COLUMN NUMBER IS #{cnum} AND THE ROW NUMBER IS #{rnum}\n"
								# if the row and columns are not nil then enter the datapoints to the proper field
								unless rnum.nil? || cnum.nil?
									if qTab[row_index,current_col + matrix_cols.length * rnum + cnum].nil?
										qTab[row_index,current_col + matrix_cols.length * rnum + cnum] =  dp.value.to_s
									else
										qTab[row_index,current_col + matrix_cols.length * rnum + cnum] =  "#{qTab[row_index,current_col + 2 * rnum + cnum]} // #{dp.value.to_s}"
									end
								# if row or column are nil then it's the 'other' field and should be entered as such 
								else
									qTab[row_index, current_col + num_columns_needed - 1] = dp.value.to_s
								end
							end
						end
					end
					current_col = current_col + num_columns_needed
				else
					unless datapoints.empty?
						
						startPoint = 0
						datapoints.each do |dp|
							# DETERMINE WHAT ROW THE DATA SHOULD GO IN BASED ON STUDY ID
							row_index = study_ids.index(dp.study_id) + 2
							sq_val = ""
							# IF IT'S NOT A TEXT QUESTION, CHECK FOR SUBQUESTION INFO
							unless ques.field_type == 'text'
								# DETERMINE IF THE FIELD ITSELF WAS ASSIGNED A SUBQUESTION
								has_sub = dp.has_subquestion
								# IF A SUBQUESTION WAS FOUND
								if !sq.nil?
									# GET THE SQ VALUE
									sq_val = dp.subquestion_value
									if sq_val.nil?
										if has_sub
											sq_val = "{{---}}"
										end
									elsif sq_val.empty?
										if has_sub
											sq_val = "{{---}}"
										end
									else
										if has_sub
											sq_val = "{{#{sq_val}}}"
										end
									end
								end # END if !sq.empty?	
							end # END unless ques.field_type == 'text	
							
							# IF NO EARLIER DATA WAS ENTERED, Aques THE VALUE TO THE CELL
							if qTab[row_index,current_col].nil?
								qTab[row_index,current_col] = "#{dp.value} #{sq_val}"
							# OTHERWISE APPEND TO WHAT ALREADY EXISTS
							else
								qTab[row_index,current_col] = qTab[row_index,current_col] + " // " + "#{dp.value} #{sq_val}"
							end
							qTab.row(row_index).set_format(current_col,formats['row_data'])							
						end	
						# NOW MARK ANY STUDIES WITHOUT AN ANSWER	
						#for i in 0..study_ids.length - 1
						#	if qTab[i+2,current_col].nil?
						#		qTab[i+2,current_col] = "---"
						#		qTab.row(i+2).set_format(current_col,formats['row_data'])							
						#	end
						#end
					else
						# OTHERWISE INDICATE THAT NO ANSWERS HAVE BEEN ENTERED
					  	#for i in 2..study_ids.length+1 
						#  	qTab[i,current_col] = '---'	
						#  	qTab.row(i).set_format(current_col,formats['row_data'])
					  	#end
					end # END unless datapoints.empty?
					qTab.column(current_col).width=19
					current_col += 1
				end # END if ques.field_type.match("matrix")
			end # END questions.each do
			for i in 2..qTab.last_row_index
				qTab.row(i).height = 40
			end
		else # AND IF questions ARE EMPTY...
			qTab.row(0).concat ["No #{model_name.gsub("_"," ")}s were created for this extraction form"]
		end # END unless questions.empty?	
	end #-------------------- END get_question_and_answers ------------------------#


	# GET_QUESTION_AND_ANSWERS_BY_ARM
	# EXPORT QUESTION-BUILDER STYLE SECTIONS WITH A QUESTION FOR EACH ARM
	# @params doc         - the excel document to add this tab to [spreadsheet object]
	# @params ef		  - the extraction form to extraction data for
	# @params studies     - an array of studies needing export  [array]
	# @params formats     - the array of spreadsheet formats to be used [array]
	# @params db_model    - the base database table, e.g. design_detail, baseline_characteristic [string]
	# @params tab_title   - the title of the tab to create [string]
	# --- options hash ---
	# @params include_total      - should we include a 'total' column? [boolean]
	#----------------------------------------------------#
	def self.get_question_and_answers_by_arm(doc, ef, studies, creators, publications, all_arms, formats, model_name, tab_title, options={"include_total"=>false} )
		# Generate the name of the model form the model_name parameter
		db_model = model_name.split("_").map{|m| m.capitalize}.join("")

		# GET A LIST OF THE STUDY IDS BEING USED FOR FUTURE REFERENCE
		study_ids = studies.collect{|x| x.id}.uniq
		col_widths = [19,15,9,26,21]

		# KEEP A RECORD OF ARM IDs for ARMS OF THE SAME TITLE
		arm_title_map = Hash.new()
		# KEEP TRACK OF WHICH STUDIES CONTAIN WHICH ARMS
		study_arms_map = Hash.new()

		#all_arms = Arm.where(:study_id => study_ids, :extraction_form_id=>ef.id)
		all_arms.each do |a|
			# UPDATE THE ARM_TITLE_MAP
			unless arm_title_map.keys.include?(a.title)
				arm_title_map[a.title] = [a.id]
			else
				arm_title_map[a.title] << a.id
			end

			# UPDATE THE STUDY_ARM_MAP
			if !study_arms_map.keys.include?(a.study_id)
				study_arms_map[a.study_id] = Array.new()
			end
			study_arms_map[a.study_id] << a.id
		end

		arm_titles = all_arms.collect{|x| x.title.strip}.uniq
		if options["include_total"]
			arm_title_map["TOTAL"] = [0]
			arm_titles << "TOTAL"
		end

		# CREATE THE WORKSHEET
		tabCount = 1
		qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
		current_col = 5

		# GET ALL OF THE QUESTIONS 
		questions = eval(db_model).where(:extraction_form_id=>ef.id).order("question_number ASC")
		puts "------------\n------------\n\nGETTING QUESTIONS BY ARM AND THERE ARE #{questions.length} questions\n\n-----------\n--------------\n\n"
		unless questions.empty?
		    questions.each do |ques|
		    	
		    	sq = ques.get_subquestion
			  	sq = sq.nil? ? "" : sq.empty? ? "" : "...#{sq}"
	    		arm_titles.each_with_index do |arm_title,arm_index|
			    	# PREPARE TO STORE MATRIX INFORMATION WHEN NECESSARY
					matrix_rows = []
					matrix_cols = []
					matrix_other = []
					num_columns_needed = 0

					# IF IT'S A MATRIX QUESTION, SET UP THE MERGED HEADER AND COLUMN/ROW COMBINATIONS
					if ques.field_type.match("matrix")
						matrix_rows = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number > ?",ques.id, 0], :order=>"row_number ASC")
	  					matrix_cols = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND column_number > ?",ques.id, 0], :order=>"column_number ASC")
	  					matrix_other = eval("#{db_model}Field").find(:all, :conditions=>["#{model_name}_id=? AND row_number < ?",ques.id, 0], :order=>"row_number DESC")
	  					if ques.field_type == 'matrix_select'
		  					num_columns_needed = matrix_cols.length * matrix_rows.length + matrix_other.length

		  					if current_col + num_columns_needed > 250
		  						tabCount += 1
								qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
								current_col = 5
		  					end
		  					# CREATE THE TITLE COLUMN
							qTab[0,current_col] = "#{ques.question} {ARM: #{arm_title}}"
		  					matrix_rows.each_with_index do |r,rowIndex|
		  						matrix_cols.each_with_index do |c,colIndex|
		  							qTab.row(0).set_format(current_col + (rowIndex * matrix_cols.length) + colIndex, formats['bold_merged'])
		  							col_row_combo = "row: #{r.option_text} // col: #{c.option_text}"
		  							qTab[1,current_col + (rowIndex * matrix_cols.length) + colIndex] = col_row_combo
		  							qTab.column(current_col + (rowIndex * matrix_cols.length) + colIndex).width = 15
		  							qTab.row(1).set_format(current_col + (rowIndex * matrix_cols.length) + colIndex, formats['centered'])
		  						end
		  					end
		  					matrix_other.each_with_index do |mo,moIndex|
		  						qTab.row(0).set_format(current_col + num_columns_needed - 1, formats['bold_merged'])
		  						qTab[1,current_col + num_columns_needed - 1] = mo.option_text
		  						qTab.row(1).set_format(current_col + num_columns_needed - 1, formats['centered'])
		  					end
		  				else
		  					num_columns_needed = matrix_rows.length + matrix_other.length
		  					if current_col + num_columns_needed > 250
		  						tabCount += 1
								qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
								current_col = 5
		  					end
		  					# CREATE THE TITLE COLUMN
							qTab[0,current_col] = "#{ques.question} {ARM: #{arm_title}}"
		  					matrix_rows.each_with_index do |r,rowIndex|
		  						qTab.row(0).set_format(current_col + rowIndex, formats['bold_merged'])
		  						qTab[1,current_col + rowIndex] = r.option_text
		  						qTab.row(1).set_format(current_col + rowIndex, formats['centered'])
		  					end
		  					unless matrix_other.empty?
		  						qTab.row(0).set_format(current_col + num_columns_needed - 1, formats['bold_merged'])
		  						qTab[1,current_col + num_columns_needed - 1] = matrix_other.first.option_text
		  						qTab.row(1).set_format(current_col + num_columns_needed - 1, formats['centered'])
		  					end
		  				end

	  				# IF IT'S NOT A MATRIX QUESTION, PUT THE SUBQUESTION ON THE NEXT ROW AND SET FORMATTING
					else
						if current_col + 1 > 250
		  					tabCount += 1
							qTab = create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
							current_col = 5
		  				end
		  				# CREATE THE TITLE COLUMN
						qTab[0,current_col] = "#{ques.question} {ARM: #{arm_title}}"
						qTab[1,current_col] = "#{sq}"
						qTab.row(0).set_format(current_col,formats['bold_centered'])
						qTab.row(1).set_format(current_col,formats['centered'])
						qTab.column(current_col).width = 19
					end
					
					# GET ANSWERS FOR ALL STUDIES
					arm_ids = arm_title_map[arm_title]
					datapoints = eval("#{db_model}DataPoint").find(:all, :conditions=>["#{model_name}_field_id=? AND study_id IN (?) AND arm_id IN (?)",ques.id, study_ids, arm_ids])
					if ques.field_type.match("matrix")
						unless datapoints.empty?
							datapoints.each do |dp|
								row_index = study_ids.index(dp.study_id) + 2
								# dp.column_field_id is zero when the quesiton is not a matrix_select type
								# if dp.column_field_id == 0
								unless ques.field_type == 'matrix_select'
									rowObj = matrix_rows.find{|mr| mr.id == dp.row_field_id}
									rnum = matrix_rows.index(rowObj)
									colObj = matrix_cols.find{|mc| mc.option_text == dp.value}
									cnum = matrix_cols.index(colObj)
									#puts "\n\nTHE ROW NUMBER IS #{rnum} AND THE COLUMN NUMBER IS #{cnum}\n\n"
									unless rnum.nil? || cnum.nil?
										if qTab[row_index,current_col + rnum].nil?
											qTab[row_index,current_col + rnum] = dp.value.to_s
										else
											qTab[row_index,current_col + rnum] = "#{qTab[row_index,current_col + rnum]} // #{dp.value.to_s}"
										end
									else
										qTab[row_index, current_col + num_columns_needed - 1] = dp.value.to_s
									end
								else
									colObj = matrix_cols.find{|mc| mc.id == dp.column_field_id}
									cnum = matrix_cols.index(colObj)
									rowObj = matrix_rows.find{|mr| mr.id == dp.row_field_id}
									rnum = matrix_rows.index(rowObj)
									#puts "\n\nTHE COLUMN NUMBER IS #{cnum} AND THE ROW NUMBER IS #{rnum}\n"
									# if the row and columns are not nil then enter the datapoints to the proper field
									unless rnum.nil? || cnum.nil?
										if qTab[row_index,current_col + matrix_cols.length * rnum + cnum].nil?
											qTab[row_index,current_col + matrix_cols.length * rnum + cnum] =  dp.value.to_s
										else
											qTab[row_index,current_col + matrix_cols.length * rnum + cnum] =  "#{qTab[row_index,current_col + 2 * rnum + cnum]} // #{dp.value.to_s}"
										end
									# if row or column are nil then it's the 'other' field and should be entered as such 
									else
										qTab[row_index, current_col + num_columns_needed - 1] = dp.value.to_s
									end
								end
							end
						end
						begin
							# get the studies that did not have data points
							studies_with_data = datapoints.collect{|x| x.study_id}.uniq
							studies_without_data = study_ids - studies_with_data
							#puts "THERE ARE #{studies_without_data.length} STUDIES WITHOUT DATA\n\n"
							# for each study without data
							studies_without_data.each do |swd|
								#puts "THE CURRENT SWD IS #{swd}\n\n"
								# determine what row the study is in
								study_row = study_ids.index(swd) + 2
								#puts "THE STUDY CAN BE FOUND IN ROW #{study_row}\n\n"
								# if the study did not contain the current arm, enter '---' for each cell
								s_arms = study_arms_map[swd].nil? ? [] : study_arms_map[swd]
								#puts "THE LENGTH OF ARMS FOR SWD IS #{s_arms.length}\n\nAND THE OVERLAP IS #{s_arms & arm_ids}\n\n}"
								if (s_arms & arm_ids).length == 0
									for col in current_col..(current_col + num_columns_needed - 1)
										qTab[study_row, col] = '---'									
									end
								end
							end
						rescue Exception=>e
							puts "EXPORTING AND HIT THE FOLLOWING EXCEPTION: #{e.message}\n\n#{e.backtrace}\n\n"
						end

						current_col = current_col + num_columns_needed
					else
						unless datapoints.empty?
							
							startPoint = 0
							datapoints.each do |dp|
								# DETERMINE WHAT ROW THE DATA SHOULD GO IN BASED ON STUDY ID
								row_index = study_ids.index(dp.study_id) + 2
								sq_val = ""
								# IF IT'S NOT A TEXT QUESTION, CHECK FOR SUBQUESTION INFO
								unless ques.field_type == 'text'
									# DETERMINE IF THE FIELD ITSELF WAS ASSIGNED A SUBQUESTION
									has_sub = dp.has_subquestion
									# IF A SUBQUESTION WAS FOUND
									if !sq.nil?
										# GET THE SQ VALUE
										sq_val = dp.subquestion_value
										if sq_val.nil?
											if has_sub
												sq_val = "{{---}}"
											end
										elsif sq_val.empty?
											if has_sub
												sq_val = "{{---}}"
											end
										else
											if has_sub
												sq_val = "{{#{sq_val}}}"
											end
										end
									end # END if !sq.empty?	
								end # END unless ques.field_type == 'text	
								
								# IF NO EARLIER DATA WAS ENTERED, Aques THE VALUE TO THE CELL
								if qTab[row_index,current_col].nil?
									qTab[row_index,current_col] = "#{dp.value} #{sq_val}"
								# OTHERWISE APPEND TO WHAT ALREADY EXISTS
								else
									qTab[row_index,current_col] = qTab[row_index,current_col] + " // " + "#{dp.value} #{sq_val}"
								end
								qTab.row(row_index).set_format(current_col,formats['row_data'])							
							end	
							# NOW MARK ANY STUDIES WITHOUT AN ANSWER	
							for i in 0..study_ids.length - 1
								if qTab[i+2,current_col].nil?
									qTab[i+2,current_col] = "---"
									qTab.row(i+2).set_format(current_col,formats['row_data'])							
								end
							end
						else
							# OTHERWISE INDICATE THAT NO ANSWERS HAVE BEEN ENTERED
						  	for i in 2..study_ids.length+1 
							  	qTab[i,current_col] = '---'	
							  	qTab.row(i).set_format(current_col,formats['row_data'])
						  	end
						end # END unless datapoints.empty?
						qTab.column(current_col).width=19
						current_col += 1
					end # END if ques.field_type.match("matrix")
				end # END arms.each do |arm|
			end # END questions.each do
			for i in 2..qTab.last_row_index
				qTab.row(i).height = 40
			end
		else # AND IF questions ARE EMPTY...
			qTab.row(0).concat ["No #{model_name.gsub("_"," ")}s were created for this extraction form"]
		end # END unless questions.empty?	
	end #-------------------- END get_question_and_answers ------------------------#
	
	# create_new_tab
	# create a new tab when the current one approaches the old excel limit of 256 columns
	def self.create_new_tab(doc, tab_title, tabCount, studies, creators, publications, formats)
		#--------------------------------------------------------------------
		col_widths = [19,15,9,26,21]
		newTab = doc.create_worksheet :name => "#{tab_title} #{tabCount == 1 ? "" : tabCount.to_s}"
			
		['Creator','Date','PMID','Title (Year)','Author'].each_with_index do |header,colNum|
			newTab.row(0).concat [header]
			newTab.row(0).set_format(colNum, formats['bold_centered'])
			newTab.row(1).set_format(colNum,formats["black_box"])
			newTab.column(colNum).width = col_widths[colNum]
		end
			
		# PUT IN STUDY TITLES AND AUTHORS
		for j in 0..(studies.length - 1)
			s = studies[j]

			## Get Primary Publication
			#prim = s.get_primary_publication
			prim = publications.find{|p| p.study_id == s.id}
			#creator = User.where(:id=>s.creator_id).select("login")
			creator = creators.find{|c| c.id == s.creator_id}
			creator = creator.nil? ? "Undefined" : creator.login

			title = "-- not defined --"
			pmid = "---"
			author = "---"
			unless prim.nil?
				title = "#{prim.title} (#{prim.year.to_s})"
				pmid = prim.pmid.to_s
				author = prim.author.to_s
			end
			## Print the study information
			newTab.row(j+2).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, title, author]

			# STYLE THE STUDY INFO
			for i in 0..4
				newTab.row(j+2).set_format(i,formats['normal_wrap'])
			end
		end	
		newTab.row(0).height = 40
		newTab.row(1).height = 30
		return newTab
	end # END NEW TAB CREATION

	# create_a_new_tab_headers_only
	# create a new tab with only the basic header information
	def self.create_new_tab_headers_only(doc, tab_title, tabCount, studies, creators, publications, formats)
		#--------------------------------------------------------------------
		col_widths = [19,15,9,26,21]
		newTab = doc.create_worksheet :name => "#{tab_title} #{tabCount == 1 ? "" : tabCount.to_s}"
			
		['Creator','Date','PMID','Title (Year)','Author'].each_with_index do |header,colNum|
			newTab.row(0).concat [header]
			newTab.row(0).set_format(colNum, formats['bold_centered'])
			newTab.column(colNum).width = col_widths[colNum]
		end
		newTab.row(0).height = 40
		return newTab
	end # END NEW TAB CREATION

	#----------------------------------------------------#
	# GET_ADVERSE_EVENT_DATA
	# SHOW ADVERSE EVENT INFORMATION RELATING TO EACH OF 
	# THE STUDIES FOUND IN THE PROJECT
	#----------------------------------------------------#	
	def self.get_adverse_event_data(doc, ef, studies, creators, publications, arms, formats)
		begin
		# Create the Tab and basic headings for the adverse events table
		tab = create_new_tab_headers_only(doc, "Adverse Events", 1, studies, creators, publications, formats)
		widths = [20,26,19,20]
		["Event Title","Event Description","Arm Title","Arm Description"].each_with_index do |header, colnum|
			tab.row(0).concat [header]
			tab.row(0).set_format(5+colnum, formats['bold_centered'])
			tab.column(5+colnum).width = widths[colnum]
		end
		startCol = 9
		# Get all adverse events for the project
		events = AdverseEvent.where(:study_id=>studies.collect{|x| x.id}, :extraction_form_id=>ef.id)
		
		# Get all datapoints for the project studies
		datapoints = AdverseEventResult.where(:adverse_event_id=>events.collect{|x| x.id})

		# Generate the column headers, one for each adverse event generated over all studies
		# keep a record of the column number that's associated with each header
		# Get Adverse Event Columns to use as table headers
		columns = AdverseEventColumn.where(:extraction_form_id=>ef.id)

		colmap = Hash.new()   # create a mapping of column ID to column index (useful for entering data later)
		
		columns.each_with_index do |c, colnum|
			tab.row(0).concat [c.name]
			tab.row(0).set_format(colnum + startCol,formats['bold_centered'])
			tab.column(colnum + startCol).width = 20
			colmap[c.id] = colnum + startCol unless colmap.keys.include?(c.id)
		end
		current_row = 1
		# for each study in the project
		studies.each do |s|

			creator = creators.find{|creat| creat.id == s.creator_id}
			creator = creator.nil? ? "Undefined" : creator.login
			primpub = publications.find{|prim| prim.study_id == s.id}
			studytitle = "-- not defined --"
			pmid = "---"
			author = "---"
			unless primpub.nil?
				studytitle = "#{primpub.title} (#{primpub.year.to_s})"
				pmid = primpub.pmid.to_s
				author = primpub.author.to_s
			end
			
			# for each adverse event associated with this study
			events.select{|e| e.study_id==s.id}.each do |event|

				# for each arm associated with this study
				arms.select{|a| a.study_id == s.id}.each do |arm|

					# create a new row including:
					#    study publication information
					#    event title 
					#    event description
					#    arm title
					#    arm description
					tab.row(current_row).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, studytitle, author]
					tab.row(current_row).concat [event.title, event.description, arm.title, arm.description]

					# enter the study adverse event data points
					datapoints.select{|d| d.arm_id == arm.id && d.adverse_event_id == event.id}.each do |dp|
						tab[current_row, colmap[dp.column_id]] = dp.value
						tab.row(current_row).set_format(colmap[dp.column_id],formats['row_data'])
					end
					for i in 0..startCol - 1
						tab.row(current_row).set_format(i,formats['normal_wrap'])
					end
					tab.row(current_row).height = 30
					current_row += 1

				end
				# now include a row for 'total (all arms)'
				tab.row(current_row).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, studytitle, author]
				tab.row(current_row).concat [event.title, event.description, "Total (All Arms)", "All Arms in the Study"]
				datapoints.select{|d| d.arm_id == -1 && d.adverse_event_id == event.id}.each do |dp|
					tab.row(current_row).set_format(colmap[dp.column_id],formats['row_data'])
				end
				for i in 0..startCol - 1
					tab.row(current_row).set_format(i,formats['normal_wrap'])
				end
				tab.row(current_row).height = 30
				current_row += 1
			end
		end
		rescue Exception=>e
			puts "ERROR: #{e.message}\n\n#{e.backtrace}"
		end
	end  # // END get_adverse_event_data


	#----------------------------------------------------#
	# GET_QUALITY_DATA
	# SHOW QUALITY INFORMATION RELATED TO EACH STUDY IN THE PROJECT
	#----------------------------------------------------#
	def self.get_quality_data(doc, ef, studies, creators, publications,formats)
		# TITLE INFORMATION
		qTab = doc.create_worksheet :name => "Study Quality"
		#qTab.row(0).concat ['Study Quality']
		#qTab.row(0).set_format(0, formats['section_title'])
		col_widths = [19,15,9,26,21]
		# GET QUALITY DIMENSION TITLES FOR THE EXTRACTION FORM
		dimensions = QualityDimensionField.where(:extraction_form_id=>ef.id).select(["id","title"])
		ratings = QualityRatingDataPoint.where(:study_id=>studies.collect{|s| s.id},:extraction_form_id=>ef.id)
		# IF RATINGS NOT EMPTY, FORM A HASH BY STUDY ID
		ratingsHash = Hash.new()
		unless ratings.empty?
			ratings.each do |r|
				ratingsHash[r.study_id] = [r.guideline_used,r.current_overall_rating,r.notes]
			end
		end
		
		unless dimensions.empty?

			['Creator','Date','PMID','Title (Year)','Author'].each_with_index do |header,colNum|
				qTab.row(0).concat [header]
				qTab.row(0).set_format(colNum, formats['bold_centered'])
				qTab.column(colNum).width = col_widths[colNum]
			end
			
			# PUT IN STUDY TITLES AND AUTHORS
			for j in 0..(studies.length - 1)
				s = studies[j]
				## Get Primary Publication
				prim = publications.find{|p| p.study_id == s.id}
				creator = creators.find{|c| c.id == s.creator_id}
				creator = creator.nil? ? "Undefined" : creator.login

				title = "-- not defined --"
				pmid = "---"
				author = "---"
				unless prim.nil?
					title = "#{prim.title} (#{prim.year.to_s})"
					pmid = prim.pmid.to_s
					author = prim.author.to_s
				end
				## Print the study information
				qTab.row(j+1).concat [creator, s.created_at.strftime("%B %d, %Y"), pmid, title, author]

				# STYLE THE STUDY INFO
				for i in 0..4
					qTab.row(j+1).set_format(i,formats['normal_wrap'])
				end
			end	
		  
		    col = 5

			# ADD COLUMN HEADERS, ONE FOR EACH TITLE
			indeces = Hash.new()
			dimensions.each do |d|
				qTab[0,col] = d.title
				qTab.row(0).set_format(col,formats['bold_centered'])
				col += 1
			end
			# ADD RATING COLUMNS
			qTab.row(0).concat ["Rating Guideline","Overall Rating","Notes"]
			qTab.row(0).set_format(col,formats['bold_centered'])
			qTab.row(0).set_format(col+1,formats['bold_centered'])
			qTab.row(0).set_format(col+2,formats['bold_centered'])
			
			
			# FILL IN THE COLUMN FOR EACH QUALITY DIMENSION
			row = 1						
			studies.collect{|s| s.id}.each do |sid|
				col=5
				datapoints = QualityDimensionDataPoint.where(:quality_dimension_field_id=>dimensions.collect{|x| x.id},:study_id=>sid).select("value")	
				unless datapoints.empty?
					# FILL IN THE DATA VALUES
					datapoints.each do |dp|
						qTab[row,col] = dp.value.empty? ? "---" : dp.value
						qTab.row(row).set_format(col,formats['row_data'])
						col += 1
					end
				else
					# IF NOTHING WAS ENTERED, TELL THE USER
				  for i in 5..3+dimensions.length - 1
				  	qTab[row,i] = '---'
				    qTab.row(row).set_format(i,formats['row_data'])
				  end
				end				
				qTab.row(row).height=40
				
				# ATTACH ANY QUALITY RATING DATA
				puts "Looking in the ratings hash for sid: #{sid}"
				unless ratingsHash[sid].nil?
					arr = ratingsHash[sid]
					puts "Found it and the array is #{arr}, (#{arr[1]})"
					nextCol = dimensions.length + 5 
					for i in 0..2
						qTab[row,nextCol + i] = arr[i]
						qTab.row(row).set_format(nextCol+i,formats['row_data'])
					end
				else
					nextCol = dimensions.length + 5 
					for i in 0..2
						qTab[row,nextCol + i] = "---"
						qTab.row(row).set_format(nextCol+i,formats['row_data'])
					end
				end
				qTab.row(row).height=40
				row += 1
			end
			# APPLY COLUMN WIDTHS
			for i in 5..qTab.column_count - 2
				qTab.column(i).width=19
			end			
			qTab.column(qTab.column_count - 1).width = 25
		else # if !dimensions.empty?
			qTab.row(1).concat ["No Quality data was entered for studies in this project."]		
		end # END unless dimensions.empty?
	end # END get_quality_data

	#----------------------------------------------------#
	# GET_RESULTS_DATA
	# Gather the results data tables for export to Excel
	#----------------------------------------------------#
	def self.get_results_data(doc, proj, ef, studies, creators, publications, all_arms, outcomes, formats)
		#puts "PARAMS: projid: #{proj.id}, efid: #{ef.id}\n\n"
		study_ids = studies.collect{|s| s.id}
		# DEFINE THE WORKSHEETS FOR RESULTS, BETWEEN ARM COMPARISONS, WITHIN ARM COMPARISONS
		resTab = doc.create_worksheet :name => "Results"
		#resTab.row(0).concat ['Results']
		#resTab.row(0).set_format(0, formats['section_title'])
		bacTab = doc.create_worksheet :name => "BACs"
		wacTab = doc.create_worksheet :name=>"WACs"

		# GET ALL UNIQUE RESULTS MEASURES FOR THIS PROJECT
		# first, we need the outcome data entry IDs
		#oc_id_set = Outcome.where(:extraction_form_id=>ef.id).select("id").collect{|oc| oc.id}
		oc_id_set = outcomes.collect{|oc| oc.id}
		all_ocdes = OutcomeDataEntry.where(:outcome_id=>oc_id_set).select("id").collect{|de| de.id}
		all_bacs = Comparison.where(:outcome_id=>oc_id_set,:within_or_between=>"between").select("id").collect{|bcomp| bcomp.id}
		all_wacs = Comparison.where(:outcome_id=>oc_id_set,:within_or_between=>"within").select("id").collect{|wcomp| wcomp.id}
		
		# now get the complete set of measures for those outcome data entries and comparisons
		all_measures = OutcomeMeasure.where(:outcome_data_entry_id=>all_ocdes).select(["id","title"])
		bac_measures = ComparisonMeasure.where(:comparison_id=>all_bacs).select(["id","title"])
		wac_measures = ComparisonMeasure.where(:comparison_id=>all_wacs).select(["id","title"])

		# store a mapping between id and title to use later
		# THOUGHT THIS NEXT LINE WOULD WORK... WHY NOT?
		#measure_map = all_measures.inject({}){|r, i| r[i.id] = i.title}
		measure_map = Hash.new()
		bac_measure_map = Hash.new()
		wac_measure_map = Hash.new()

		all_measures.each do |m|
			measure_map[m.id] = m.title
		end
		bac_measures.each do |m|
			bac_measure_map[m.id] = m.title
		end
		wac_measures.each do |m|
			wac_measure_map[m.id] = m.title
		end

		# get only the unique measures
		all_measures = all_measures.collect{|x| x.title}.uniq
		bac_measures = bac_measures.collect{|x| x.title}.uniq
		wac_measures = wac_measures.collect{|x| x.title}.uniq

		#----------------------
		# THE FIRST ROW 
		#----------------------
		# write the first row of each tab
		
		resTab.row(0).concat ['Creator','Date','PMID','Title (Year)','Author','Outcome','Outcome Units','Outcome Type','Outcome Description','Subgroup','Timepoint','Arm']
		for i in 0..11
			resTab.row(0).set_format(i,formats['bold_centered'])
			resTab.column(i).width = 19 unless [2,3,8].include?(i)
		end
		resTab.column(2).width = 9
		resTab.column(3).width = 26
		resTab.column(8).width = 22
		

		
		bacTab.row(0).concat ['Creator','Date','PMID','Title (Year)','Author','Outcome','Outcome Units','Outcome Type','Outcome Description','Subgroup','Timepoint','Comparator']
		wacTab.row(0).concat ['Creator','Date','PMID','Title (Year)','Author','Outcome','Outcome Units','Outcome Type','Outcome Description','Subgroup','Comparator','Arm']
		[bacTab,wacTab].each do |tab|
			for i in 0..11
				tab.row(0).set_format(i,formats['bold_centered'])
				tab.column(i).width = 19 unless [2,3,8].include?(i)
			end
			tab.column(2).width = 9
			tab.column(3).width = 26
			tab.column(8).width = 22
		end
		resTab.column(8).width = 22

		# ADD COLUMN HEADERS, ONE FOR EACH MEASURE
		measures_start = 12
		col = 12
		all_measures.each do |m|
			resTab[0,col] = m
			resTab.row(0).set_format(col,formats['bold_centered'])
			resTab.column(col).width = 19
			col += 1
		end

		bac_col = 12
		bac_measures.each do |m|
			bacTab[0,bac_col] = m
			bacTab.row(0).set_format(bac_col,formats['bold_centered'])
			bacTab.column(bac_col).width = 19
			bac_col += 1
		end
		wac_col = 12
		wac_measures.each do |m|
			wacTab[0,wac_col] = m
			wacTab.row(0).set_format(wac_col,formats['bold_centered'])
			wacTab.column(wac_col).width = 19
			wac_col += 1
		end

		#-----------------------
		# ROW 2 - ?
		#-----------------------
		curr_id = ""
		curr_title = ""
		curr_author = ""
		curr_pmid = ""
		curr_results = Array.new()
		rowCount = 1
		bacRowCount = 1
		wacRowCount = 1
		unless all_ocdes.empty?
			studies.each do |s|
				# collect arm titles for use building this table
				#arms = s.arms.select(["id","title"])
				arms = all_arms.select{|a| a.study_id == s.id}
				arms_ref = Hash.new()
				arms.each do |a|
					arms_ref[a.id] = a.title
				end
				res = s.get_existing_results_for_session

				# get the study information
				prim = publications.find{|p| p.study_id == s.id}
				creator = creators.find{|c| c.id == s.creator_id}
				creator = creator.nil? ? "Undefined" : creator.login

				curr_title = "-- not defined --"
				curr_pmid = "---"
				curr_author = "---"
				unless prim.nil?
					curr_title = "#{prim.title} (#{prim.year.to_s})"
					curr_pmid = prim.pmid.to_s
					curr_author = prim.author.to_s
				end
				oc_titles = Hash.new()
				sg_titles = Hash.new() 
				tp_titles = Hash.new()

				oc_title = ""
				oc_description = ""
				oc_units = ""
				oc_type = ""
				# loop through the results hash keys
				# (outcomeTitle_outcomeID_subgroupTitle_subgroupID)
				res.keys.each do |resKey|
					key_parts = resKey.split("_")
					oc_title = key_parts[0]
					oc_id = key_parts[1]
					oc = outcomes.find{|o| o.id == oc_id.to_i}
					unless oc.nil?
						oc_description = oc.description
						oc_type = oc.outcome_type
						oc_units = oc.units
					end
					sg_title = key_parts[2]
					sg_id = key_parts[3]
					# store the titles for use in the comparisons table
					oc_titles[oc_id] = oc_title
					sg_titles[sg_id] = sg_title

					# for each outcome data entry associated with this record
					res[resKey].each do |res_array|

						# get the ocde object at the front of this array
						ocde_obj = res_array[0]

						# get the timepoint title
						
						if !tp_titles.keys.include?(ocde_obj.timepoint_id)
							tp_titles[ocde_obj.timepoint_id] = OutcomeTimepoint.get_title(ocde_obj.timepoint_id)
							
						end
						tp_title = tp_titles[ocde_obj.timepoint_id]

						ocde_dps = res_array[2]
						# for each of the included measures
						study_measures = res_array[1].collect{|m| m.title}
						arms_ref.keys.each do |armID|
							resTab.row(rowCount).concat [creator,s.created_at.to_s,curr_pmid, curr_title, curr_author, oc_title, oc_units, oc_type, oc_description, sg_title, tp_title, arms_ref[armID]] unless res_array[1].empty?
							res_array[1].each do |meas|
								col_pos = measures_start + all_measures.index(meas.title)
								# if there are datapoints for this measure, start going through the arms
								if ocde_dps.keys.include?(meas.id)
									if ocde_dps[meas.id].keys.include?(armID)
										resTab[rowCount,col_pos] = ocde_dps[meas.id][armID].value.blank? ? "" : ocde_dps[meas.id][armID].value
									else
										# LETS JUST LEAVE THE CELL BLANK IF NO DATA WAS ENTERED
										#resTab[rowCount,col_pos] = "NO DATA"
									end
									#resTab.row(rowCount).set_format(col_pos)
								end
							end
							# blank out any of the columns where the measure simply doesn't apply to this study
							all_measures.each do |m|
								if study_measures.index(m) == nil
									resTab[rowCount,measures_start+all_measures.index(m)] = "---"
									#resTab.row(rowCount).set_format(measures_start+all_measures.index(m),formats['black_box'])
								end	
							end
							rowCount += 1
						end
					end # end res[resKey].each do |resArray|
				end # end res.keys.each do key
			
				#--------------------------
				# COMPARISONS
				#--------------------------
				unless all_bacs.empty? && all_wacs.empty?
					study_comparisons = OutcomeDataEntry.get_existing_comparisons_for_session(s.get_data_entries)
					btwn = study_comparisons[:between]
					within = study_comparisons[:within]

					#---------------
					# BETWEEN ARM
					#---------------
					unless btwn.empty?
						#puts "Entered between-arm comparison export.\n"
						btwn.keys.each do |key|
							#puts "Starting key: #{key}...\n"
							ocid,sgid = key.split("_")
							unless btwn[key].empty?
								comp_array = btwn[key].first # get the result data. The second position contains the comparator name
								compObj = comp_array.first
								comparators = comp_array[1]
								meas = comp_array[2]
								bac_data = comp_array[3]

								# for each comparator in the comparison
								comparators.each do |comparator|
									comparator_string = Comparator.find(comparator)
									comparator_string = comparator_string.to_string('between')
									#puts "----------- starting a new line ----------------\n"
									#puts "Working on comparator #{comparator_string}\n"
									#puts "the bacRowCount is #{bacRowCount}\n"
									# print the first part of the row
									bacTab.row(bacRowCount).concat [creator,s.created_at.to_s,curr_pmid, curr_title, curr_author, oc_titles[ocid], oc_units, oc_type, oc_description, sg_titles[sgid], tp_titles[compObj.group_id], comparator_string] unless comparators.empty?
									#puts "Wrote the first 8 columns.\n"
									# for each measure in the comparison
									#puts "Now starting with the measures.\n"
									#puts "WORKING ON STUDY: #{curr_title} (#{creator}) AND COMPARATOR #{comparator_string} AND COMP IS #{compObj.id}\n"
									meas.each do |m|	
										#puts "CURRENT MEASURE IS #{m}\n"
										#unless m.class != ComparisonMeasure
											# print the datapoint
											col_pos = measures_start + bac_measures.index(m.title)
											#puts "Column position is #{col_pos}\n\n"
											# if there are datapoints for this measure, start going through the arms
											if bac_data.keys.include?("#{m.id}_#{comparator}")
												#bacTab[bacRowCount,col_pos] = bac_data["#{m.id}_#{comparator}"].empty? ? "---" : bac_data["#{m.id}_#{comparator}"].value.blank? ? "LEFT EMPTY" : bac_data["#{m.id}_#{comparator}"].value
												#bacTab[bacRowCount,col_pos] = bac_data["#{m.id}_#{comparator}"].class != ComparisonDataPoint ? "LEFT EMPTY" : (bac_data["#{m.id}_#{comparator}"].value.blank? ? "LEFT EMPTY" : bac_data["#{m.id}_#{comparator}"].value)
												bacTab[bacRowCount,col_pos] = bac_data["#{m.id}_#{comparator}"].class != ComparisonDataPoint ? " " : (bac_data["#{m.id}_#{comparator}"].value.blank? ? " " : bac_data["#{m.id}_#{comparator}"].value)
											end
										#end
										#else
										#	bacTab[bacRowCount,bac_measures.index(m)] = "A PROBLEM OCCURED."
										#end
									end
									# blank out any of the columns where the measure simply doesn't apply to this study
#begin
									#puts "going through bac measures again to add in dashes where applicable.\n\n"
									meas_titles = meas.collect{|me| me.title}
									bac_measures.each do |m|
										#puts "On measure #{m}\n"
										if meas_titles.index(m) == nil
											#puts "Couldn't find it, so adding a ---\n\n"
											bacTab[bacRowCount,measures_start+bac_measures.index(m)] = "---"
											#resTab.row(rowCount).set_format(measures_start+all_measures.index(m),formats['black_box'])
										end	
									end
#end
									#puts "Moving to next row.\n\n"
									bacRowCount += 1 
									#puts "bacRowCount is now #{bacRowCount}\n\n"
								end # end comparators.each do comparator
							end #unless btwn[key].empty?
						end #end btwn.keys.each do key
					end # end unless btwn.empty?					
					#---------------
					# WITHIN ARM
					#---------------
					unless within.empty?
						within.keys.each do |key|
							ocid,sgid = key.split("_")
							unless within[key].empty?
								# get the array of data for this comparison
								comp_array = within[key].first # get the result data. The second position contains the comparator name
								# position 0 = the comparison object
								# position 1 = the ID of the comparator
								# position 2 = the comparator title
								# position 3 = an array of measure objects
								# position 4 = a hash of data point objects, referenced by a key measureID_comparatorID_armID
								compObj = comp_array.first
								comparator_id = comp_array[1]
								comparator_title = comp_array[2]
								meas = comp_array[3]
								associated_measures = meas.collect{|x| x.title}.uniq
								wac_data = comp_array[4]
								
								# loop through the arms and create a row for each combination of comparator and arm
								arms_ref.keys.each do |armID|
									wacTab.row(wacRowCount).concat [creator,s.created_at.to_s,curr_pmid, curr_title, curr_author, oc_titles[ocid], oc_units, oc_type, oc_description, sg_titles[sgid], comparator_title, arms_ref[armID]]
									# for each wac measure, see if there's an associated datapoint and if so, put it in.
									# if there's no datapoint, then put in the dashes (---)
									wac_measures.each_with_index do |wm,i|
										associated_index = associated_measures.index(wm)
										if associated_index.nil?
											wacTab[wacRowCount, 12 + i] = '---'
										else
											dpkey = "#{meas[associated_index].id}_#{comparator_id}_#{armID}"
											dpval = wac_data[dpkey].nil? ? '   ' : wac_data[dpkey].value
											wacTab[wacRowCount, 12 + i] = dpval
										end
									end
									wacRowCount += 1
								end
							end #unless within[key].empty?
						end #end within.keys.each do key
					end # end unless within.empty?
				end # unless all_bacs.empty and all_wacs.empty
			end # end studies.each do study
		end	# end unless all_ocdes.empty?
	end # END get_results_data
	def self.project_studies workbook
	end	
	
	def self.project_extraction_forms workbook
	end
end