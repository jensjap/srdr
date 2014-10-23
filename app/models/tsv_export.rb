###############################################################################
# This class contains code for exporting various parts of a systematic review #
# to Microsoft Excel format. 																									#
###############################################################################

class TsvExport
	
	# export all information related to a systematic review project
	# a file for project information (contains key questions, study listing, extraction form listing)
	# a file for extraction forms (contains 1 per tab)
	# a file for studies/extracted data (extracted data?)
	def self.project_to_tsv proj_id, user 
		proj = Project.find(proj_id)
		files = Array.new
		doc = Spreadsheet::Workbook.new # create the workbook
		
		# EXCEL FORMATTING 
		section_title = Spreadsheet::Format.new(:weight => :bold, :size => 14) 
		bold = Spreadsheet::Format.new(:weight=>:bold,:align=>'center',:vertical_align=>'top')
		bold_centered = Spreadsheet::Format.new(:weight => :bold, :align=>"center", :text_wrap=>true) 
		normal_wrap = Spreadsheet::Format.new(:text_wrap => true,:vertical_align=>"top")
		row_data = Spreadsheet::Format.new(:text_wrap => true,:align=>"center",:vertical_align=>"top")
		formats = {'section_title'=>section_title,'bold'=>bold,'bold_centered'=>bold_centered,
		          'normal_wrap'=>normal_wrap,'row_data'=>row_data}
		doc.add_format(section_title)
		doc.add_format(bold)
		doc.add_format(bold_centered)
		doc.add_format(normal_wrap)
		doc.add_format(row_data)
		
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
				study_ids = StudyExtractionForm.where(:extraction_form_id=>ef.id).select("study_id")
				study_ids = study_ids.collect{|x| x.study_id}
				studies = Study.where(:id=>study_ids).select("id") # have study objects available for function calls
				# ADDING THIS HERE IN ORDER TO OUTPUT ONLY ONE FILE
				# REMOVE THIS SECTION AND UNCOMMENT THE TOP PORTION FOR THE ZIPPED VERSION
				self.get_project_info(doc,proj,formats)
				self.get_project_users(doc,proj,formats)
				
				unless study_ids.empty?
					sections = ExtractionFormSection.where(:extraction_form_id=>ef.id, :included=>true).select(:section_name)
					sections = sections.collect{|x| x.section_name}
					unless sections.empty?
					  if sections.include?('arms')
					  	self.get_project_arms(doc,ef,studies,study_ids,formats)
					  end
					  if sections.include?('outcomes')
					  	self.get_project_outcomes(doc,ef,studies,study_ids,formats)
					  end
					  if sections.include?('design')
					  	self.get_design_details(doc,ef,studies,study_ids,formats)
					  end
					  if sections.include?('baselines')
					  	self.get_baseline_characteristics(doc,ef,studies,study_ids,formats)
					  end
					  if sections.include?('quality')
					  	self.get_quality_data(doc,ef,studies,study_ids,formats)
					  end
					end
				end
				#tmpFilename = "#{user.login.to_s}_project_data_ef_#{i.to_s}.xls"
				#doc.write "exports/#{tmpFilename}"
				#files << tmpFilename
				#i+=1
			#UNCOMMENT THIS IN ZIPPED VERSION
			#end
		end
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
	  
	  # title of sheet
	  info.row(0).concat ["General Project Information"]
	  info.row(0).set_format(0,formats['section_title'])
	  
	  # creator
	  user = User.find(project.creator_id)
	  user_info = user.to_string
	  info.row(1).concat ["Creator", user_info]
	  info.row(2).concat ["Organization",user.organization]
	  
	  # basic info
	  info.row(3).concat ["Title", project.title]
	  info.row(4).concat ["Description", project.description.to_s]
	  info.row(5).concat ["Funding Agency", project.funding_source.to_s]
	  info.row(6).concat ["Notes", project.notes.to_s]
	  	  	  
	  # key questions
	  current_row = 7
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
	  
	  utab.row(0).concat ['Project Team Members']
	  utab.row(0).set_format(0,formats['section_title'])
	  
	  team_members = UserProjectRole.where(:project_id=>project.id).order("role DESC")
	  unless team_members.empty?
	  	# user headings
	  	utab.row(1).concat ['User Role','Name','Email']
	  	
	  	utab.row(1).set_format(0,formats['bold_centered'])
	  	utab.row(1).set_format(1,formats['bold_centered'])
	  	utab.row(1).set_format(2,formats['bold_centered'])
	  	
	  	# list the users
	  	current_row=2
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
	  	utab.row(1).concat ['There are no users associated with this project.']
	  end
	end
	#-------------- END get_project_users --------------------#
	#--------------------------------------------------------------------------
	# GET_PROJECT_ARMS
	# ADD A WORKSHEET CONTAINING A TABLE OF ARM ASSIGNMENTS FOR THE PROJECT
	#--------------------------------------------------------------------------
	def self.get_project_arms(doc,ef,studies,study_ids,formats)
		armsTab = doc.create_worksheet :name => "Study Arms"
		armsTab.row(0).concat ['Study Arms']
		armsTab.row(0).set_format(0, formats['section_title'])
		
		uniq_arms = Arm.where(:study_id => study_ids, :extraction_form_id=>ef.id)
		uniq_arms = uniq_arms.collect{|a| (a.title + "|+|+|+|" + a.description)}.uniq
		col_index = 3
		unless uniq_arms.empty?
			uniq_arms.each do |arm|
				index = uniq_arms.index(arm)
				# if it's the first arm in the list, add in the study & pmid headers
				if index == 0
					armsTab.row(1).concat ['PMID','Title (Year)','Author']
					armsTab.row(1).set_format(0,formats['bold_centered'])					
					armsTab.row(1).set_format(1,formats['bold_centered'])
					armsTab.row(1).set_format(2,formats['bold_centered'])
					# put in the study titles and authors
					for j in 0..(study_ids.length - 1)
						stud = studies[j]
						primary = stud.get_primary_publication
						title = "#{primary.title} (#{primary.year.to_s})"
						armsTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s ]
						armsTab.row(j+2).set_format(0,formats['normal_wrap'])
						armsTab.row(j+2).set_format(1,formats['normal_wrap'])
						armsTab.row(j+2).set_format(2,formats['normal_wrap'])
					end	
			  end # end if index == 0
				
				# add a column header for this arm
			  split = arm.split("|+|+|+|")
			  title = split[0]
			  description = split[1]
			  armsTab[1,col_index] = "#{title} (#{description})"
			  armsTab.row(1).set_format(col_index, formats['bold_centered'])
			  
				# determine which studies in the project use this arm						  
			  included_studies = Arm.where(:extraction_form_id=>ef.id, :title=>title, :description=>description).select("study_id")
			  included_studies = included_studies.collect{|x| x.study_id}
			  row_index = 2
			  study_ids.each do |sid|
			  	if included_studies.include?(sid)
			  		armsTab[row_index,col_index] = 1
			  	else
			  		armsTab[row_index,col_index] = 0
			  	end
			  	armsTab.row(row_index).set_format(col_index,formats['row_data'])
			  	row_index += 1
			  end
			  col_index += 1
			end # end uniq_arms.each do
		  # SET WIDTHS AND HEIGHTS
			for i in 2..armsTab.last_row_index do
			  armsTab.row(i).height=40
			end
			for j in 0..armsTab.column_count - 1 do
				width = 19
				if j == 0
					width=9
				elsif j == 1
					width=26
				end
				armsTab.column(j).width = width
			end
		else
			armsTab.row(1).concat ['There were no arms defined for this extraction form.']
		end # end unless uniq_arms.empty?
	end
	#-------------- END ARMS TABS --------------------#
	
	#----------------------------------------------------#
	# GET_PROJECT_OUTCOMES
	# RETURN OUTCOMES ASSOCIATED WITH THE PROJECT. ONE TAB WILL
	# SHOW OUTCOME ASSIGNMENTS WHILE ANOTHER WILL PROVIDE DETAILS
	# REGARDING EACH OUTCOME
	#----------------------------------------------------#
	def self.get_project_outcomes(doc,ef,studies,study_ids,formats)
		# CREATE THE OUTCOMES WORKSHEET
		ocTab = doc.create_worksheet :name => "Outcomes"
		ocTab.row(0).concat ['Outcomes Assigned']
		ocTab.row(0).set_format(0,formats['section_title'])
		
		# CREATE THE OUTCOME INFO WORKSHEET
		ocInfoTab = doc.create_worksheet :name => "Outcome Info"
		ocInfoTab.row(0).concat ['Outcome Info']
		ocInfoTab.row(0).set_format(0,formats['section_title'])
		
		# GET THE SET OF UNIQUE OUTCOMES FOR THE PROJECT (BASED ON TITLE)
		outcome_objs = Outcome.where(:extraction_form_id=>ef.id, :study_id=>study_ids)
		unless outcome_objs.empty?
			#uniq_outcomes = outcome_objs.collect{|x| "#{x.title}|+|+|+|#{x.description}"}
			uniq_outcomes = outcome_objs.collect{|x| x.title}.uniq
			
			
			# ADD STUDY COLUMN HEADERS FOR BOTH OUTCOME TABS
			iter = 0 # the column number
			heads = ['PMID','Title (Year)','Author']
			heads.each do |title|
				ocTab[1,iter] = title
				ocInfoTab[1,iter] = title
				ocTab.row(1).set_format(iter,formats['bold_centered'])
				ocInfoTab.row(1).set_format(iter,formats['bold_centered'])
				iter+=1
			end
			
			# ENTER STUDY INFO FOR OUTCOMES TAB
			for j in 0..(study_ids.length - 1)
				stud = studies[j]
				primary = stud.get_primary_publication
				title = "#{primary.title} (#{primary.year.to_s})"
				ocTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s ]
				ocTab.row(j+2).set_format(0,formats['normal_wrap'])
				ocTab.row(j+2).set_format(1,formats['normal_wrap'])
				ocTab.row(j+2).set_format(2,formats['normal_wrap'])
			end	
			
			# BUILD THE COLUMN HEADERS FOR THE OUTCOMES TAB AND ENTER DATA
			iter = 3 # the column number
			uniq_outcomes.each do |oc|
				#octitle = oc.split("|+|+|+|")[0]
				#ocdesc = oc.split("|+|+|+|")[1]
				#ocTab[1,iter] = "#{octitle} (#{ocdesc})"
				ocTab[1,iter] = oc
				ocTab.row(1).set_format(iter,formats['bold_centered'])
				
				# DETERMINE WHICH STUDIES CONTAIN THE OUTCOME
				included_studies = Outcome.where(:extraction_form_id=>ef.id,:title=>oc).select("study_id")
				#included_studies = Outcome.where(:extraction_form_id=>ef.id,:title=>octitle,:description=>ocdesc).select("study_id")
				unless included_studies.empty?
					included_studies = included_studies.collect{|x| x.study_id}
				
					rowid = 2
					study_ids.each do |sid|
				  	if included_studies.include?(sid)
				  		ocTab[rowid,iter] = 1
				  	else
				  		ocTab[rowid,iter] = 0
				  	end
				  	ocTab.row(rowid).set_format(iter,formats['row_data'])
				  	rowid += 1
					end
				else
					for i in 2..2+study_ids.length - 1
						ocTab[i,iter] = 0
						ocTab.row(i).set_format(iter,formats['row_data'])
					end
				end
				iter += 1
			end
			
			# STRUCTURE THE OUTCOMES TAB
			ocTab.column(0).width = 8
			ocTab.column(1).width = 25
			ocTab.column(2).width = 18
			for i in 3..ocTab.column_count - 1
				ocTab.column(i).width = 19
			end
			for i in 2..ocTab.last_row_index-1
				ocTab.row(i).height=40
			end
			# FILL IN THE OUTCOME INFO TAB
			ocInfoTab.row(1).concat ['Title','Description','Unit(s)','Timepoint(s)','Primary?','Type','Note(s)']
			rowid = 2
			studies_covered = []
			outcome_objs.each do |ocobj|
				stud = studies[study_ids.index(ocobj.study_id)]
			  primary = stud.get_primary_publication
			  unless studies_covered.include?(stud.id)
			  	studies_covered << stud.id
			  end
				title = "#{primary.title} (#{primary.year.to_s})"
				ocInfoTab.row(rowid).concat [primary.pmid, title, primary.author]
				is_primary = ocobj.is_primary ? "Yes" : "No"
				tps = Outcome.get_timepoints(ocobj.id)
				ocInfoTab.row(rowid).concat [ocobj.title, ocobj.description,ocobj.units, tps, is_primary, ocobj.outcome_type, ocobj.notes]
				rowid += 1
			end
			
			# FOR ANY STUDIES THAT WERE NOT INCLUDED, INDICATE THAT THEY DIDN'T HAVE OUTCOMES
			study_ids.each do |sid|
				unless studies_covered.include?(sid)
					stud = studies[study_ids.index(sid)]
			  	primary = stud.get_primary_publication
			  	title = "#{primary.title} (#{primary.year.to_s})"
					ocInfoTab.row(rowid).concat [primary.pmid, title, primary.author, '-- No Outcomes --']
					for i in 4..ocInfoTab.column_count - 1
						ocInfoTab[rowid,i] = '---'
					end
					rowid += 1
			  end
			end
			# FORMAT THE OUTCOME INFO TAB
			for i in 1..ocInfoTab.last_row_index
				for j in 0..ocInfoTab.column_count - 1
				  if i == 1
				  	ocInfoTab.row(i).set_format(j,formats['bold_centered'])
				  else
				  	if j < 3
				  		ocInfoTab.row(i).set_format(j,formats['normal_wrap'])
				  	else
				  		unless j == 4
				  			ocInfoTab.row(i).set_format(j,formats['row_data'])
				  		else
				  			ocInfoTab.row(i).set_format(j,formats['normal_wrap'])
				  		end
				  	end
				  end	
				  if [3,5].include?(j)
				  	ocInfoTab.column(j).width = 20
				  elsif [7,9].include?(j)
				  	ocInfoTab.column(j).width = 40
				  end
				end
				if i > 1
					ocInfoTab.row(i).height = 40
				end	
			end
			ocInfoTab.column(0).width = 8
	  	ocInfoTab.column(1).width = 26
	  	ocInfoTab.column(2).width = 18
			ocInfoTab.column(3).width = 20
			ocInfoTab.column(4).width = 40
			ocInfoTab.column(5).width = 15
	  	ocInfoTab.column(6).width = 20
	  	ocInfoTab.column(7).width = 10
	  	ocInfoTab.column(8).width = 10
			ocInfoTab.column(9).width = 40
		else # OTHERWISE, IF THERE ARE NO OUTCOMES...
			ocTab.row(1).concat ['There are no outcomes defined for this project.']
			ocInfoTab.row(1).concat ['There are no outcomes defined for this project.']
		end
	end
	#-------------- END OUTCOMES TABS --------------------#
	#----------------------------------------------------#
	# GET_DESIGN_DETAILS
	# SHOW DESIGN DETAIL QUESTIONS AND ANSWERS FOR ALL STUDIES IN THE PROJECT
	#----------------------------------------------------#
	def self.get_design_details(doc,ef,studies,study_ids,formats)
		# CREATE THE DESIGN DETAILS WORKSHEET
		designTab = doc.create_worksheet :name => "Design Details"
		designTab.row(0).concat ['Design Details']
		designTab.row(0).set_format(0, formats['section_title'])
		
		# GET ALL DESIGN DETAILS
		dds = DesignDetail.where(:extraction_form_id=>ef.id).order("question_number ASC")
		unless dds.empty?
			designTab.row(1).concat ['PMID','Title (Year)','Author']
			designTab.row(1).set_format(0,formats['bold_centered'])
			designTab.row(1).set_format(1,formats['bold_centered'])
			designTab.row(1).set_format(2,formats['bold_centered'])
			
			# PUT IN STUDY TITLES AND AUTHORS
			for j in 0..(study_ids.length - 1)
				stud = studies[j]
				primary = stud.get_primary_publication
				title = "#{primary.title} (#{primary.year.to_s})"
				designTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s ]
				# STYLE THE STUDY INFO
				for i in 0..2
					designTab.row(j+2).set_format(i,formats['normal_wrap'])
				end
			end	
		  
		  current_col = 3
			# LOOP THROUGH THE DESIGN DETAILS
		  dds.each do |dd|
		  	current_row = 2
				
		  	# FOR ANY SIMPLE TEXT FIELDS...
		  	#------------------------------
		  	if dd.field_type == 'text'
				  # CREATE THE TITLE COLUMN
				  designTab.row(1).concat [dd.question]  
				  designTab.row(1).set_format(current_col,formats['bold_centered'])
				  # FILL IN ANSWERS FOR EACH STUDY
				  study_ids.each do |sid|
				  	datapoint = DesignDetailDataPoint.where(:design_detail_field_id=>dd.id, :study_id=>sid, :extraction_form_id=>ef.id).select(["value","subquestion_value"])
				  	val = ""
				  	unless datapoint.empty? || datapoint.nil?
				  		if datapoint.first.value == ""
				  			val = "--no answer--"
				  		else
				  			val = datapoint.first.value
				  		end
				  	end
				  	designTab[current_row,current_col] = val
				  	current_row += 1
				  end # END study_ids.each do |sid|	
				  current_col += 1
				  
				# FOR RADIO, CHECKBOXES, SELECT BOX DESIGN DETAIL FIELDS
				#--------------------------------------------------------
				elsif ['radio','checkbox','select'].include?(dd.field_type)							  	
					# GET THE DESIGN DETAIL FIELDS
					ddfields = DesignDetailField.where(:design_detail_id=>dd.id)
					ddfield_values = ddfields.collect{|x| x.option_text}
					
					indeces = Hash.new # KEEPS TRACK OF COLUMN INDECES FOR EACH FIELD
	       
					# LOOP THROUGH DESIGN DETAIL FIELDS
					unless ddfields.empty?
						# ADD COLUMN HEADERS...
						col_count = current_col
						iterator = 0
						ddfields.each do |field|
							# NOTE QUESTION COL TO ACCOUNT FOR SUBQUESTIONS
							indeces[iterator] = col_count 
							designTab[1,col_count] = "#{dd.question.to_s}::#{field.option_text}"
							designTab.row(1).set_format(col_count,formats['bold_centered'])
							if field.has_subquestion
								designTab[1,col_count+1] = "SUBQUESTION: #{field.subquestion}"
								designTab.row(1).set_format(col_count+1,formats['bold_centered'])
								col_count += 2
							else
								col_count += 1
							end
							iterator += 1
						end # END ddfields.each do |field|
						
						current_col = col_count
						# ENTER ANY QUESTION VALUES FOR EACH STUDY
						current_row = 2
						study_ids.each do |sid|
						  datapoint = DesignDetailDataPoint.where(:design_detail_field_id=>dd.id, :study_id=>sid, :extraction_form_id=>ef.id).select(["value", "subquestion_value"])
						  unless datapoint.nil?
						  	datapoint.each do |dp|
							  	val = dp.value
							  	field = ddfields[ddfield_values.index(val)] # GET THE CORRESPONDING FIELD OBJ
							  	col = indeces[ddfield_values.index(val)] # DETERMINE THE PROPER COLUMN
							  	# ADD SUBQUESTION DATA
							  	subval = field.has_subquestion ? dp.subquestion_value : ""
							  	designTab[current_row, col] = 1
						  		designTab[current_row,col+1] = subval if field.has_subquestion
						  	end # END datapoint.each do |dp|
						  	# FILL IN ZEROS FOR AN OPTIONS NOT CHOSEN
					  		for i in (current_col-(ddfields.length+dd.design_detail_fields.where(:has_subquestion=>true).count))..current_col-1
					  			if designTab[current_row,i].nil?
					  				designTab[current_row,i] = 0
					  			end
					  		end
						  else
						  	# FILL IN '---' BECAUSE IT WASN'T ANSWERED
					  		for i in (current_col-(ddfields.length+dd.design_detail_fields.where(:has_subquestion=>true).count))..current_col-1
				  				designTab[current_row,i] = '---'
					  		end
						  end
						  current_row += 1
						end # end study_ids.each do |sid|
					end # end unless ddfields.empty?
				end
			end # end dds.each do |dd|
			# STYLE THE DESIGN DETAILS DATA
			#------------------------------------------
			for i in 2..designTab.last_row_index
				for j in 0..designTab.column_count-1
					if j > 2
						designTab.row(i).set_format(j,formats['row_data'])
					end
					# ASSIGN ROW HEIGHTS
					designTab.row(i).height=40
				end
			end
			# ASSIGN COLUMN WIDTHS
			designTab.column(0).width=9
			designTab.column(1).width=26
			for i in 2..designTab.column_count-1
				designTab.column(i).width=19
			end
		else # AND IF DDS ARE EMPTY...
			designTab.row(1).concat ['No design details were created for this extraction form']
		end # END unless dds.empty?
	end #-------------------- END get_design_details ------------------------#
	
	#----------------------------------------------------#
	# GET_BASELINE_CHARACTERISTICS
	# SHOW DESIGN DETAIL QUESTIONS AND ANSWERS FOR ALL STUDIES IN THE PROJECT
	#----------------------------------------------------#
	def self.get_baseline_characteristics(doc,ef,studies,study_ids,formats)
		# CREATE THE BASELINE CHARACTERISTICS
		bcTab = doc.create_worksheet :name => "Baseline Characteristics"
		bcTab.row(0).concat ['Baseline Characteristics']
		bcTab.row(0).set_format(0, formats['section_title'])

		# GET ALL BASELINE CHARACTERISTICS
		bcs = BaselineCharacteristic.where(:extraction_form_id=>ef.id).order("question_number ASC")
		unless bcs.empty?
			arm_not_found = '- arm not found -'
			bcTab.row(1).concat ['PMID','Title (Year)','Author']
			
			# ADD STUDY TITLES AND AUTHORS
			#-----------------------------
			for j in 0..(study_ids.length - 1)
				stud = studies[j]
				primary = stud.get_primary_publication
				title = "#{primary.title} (#{primary.year.to_s})"
				bcTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s]
				# STYLE THE STUDY INFO
				for i in 0..2
					bcTab.row(j+2).set_format(i,formats['normal_wrap'])
				end
			end	
			
			current_col = 3
			# MAKE A COPY OF UNIQ_ARMS FOR BC USE
			bc_arms = Arm.where(:study_id => study_ids, :extraction_form_id=>ef.id)
			bc_arms = bc_arms.collect{|a| (a.title + "|+|+|+|" + a.description)}.uniq
			bc_arms << "TOTAL|+|+|+|None"
			
			# FOR EACH BASELINE CHARACTERISTIC
			tabCount = 1
			bcs.each do |bc|
				if current_col >= 150
					tabCount += 1
					bcTab = doc.create_worksheet :name => "Baseline Characteristics #{tabCount}"
					# ADD STUDY TITLES AND AUTHORS
					#-----------------------------
					for j in 0..(study_ids.length - 1)
						stud = studies[j]
						primary = stud.get_primary_publication
						title = "#{primary.title} (#{primary.year.to_s})"
						bcTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s]
						# STYLE THE STUDY INFO
						for i in 0..2
							bcTab.row(j+2).set_format(i,formats['normal_wrap'])
						end
					end
					current_col = 3
				end	
				# IF THE FIELD TYPE IS TEXT...
				#--------------------------------------------
				if bc.field_type == "text"
					# IF WE'RE GOING OVER THE COLUMN THRESHOLD FOR EXCEL, START A NEW TAB
					#--------------------------------------------------------------------
				  if current_col + bc_arms.length > 250
				  	tabCount += 1
						bcTab = doc.create_worksheet :name => "Baseline Characteristics #{tabCount}"
						bcTab.row(1).concat ['PMID','Title (Year)','Author']
						for i in 0..2
							bcTab.row(1).set_format(i,formats['bold_centered'])
						end
						
						# ADD STUDY TITLES AND AUTHORS
						#-----------------------------
						for j in 0..(study_ids.length - 1)
							stud = studies[j]
							primary = stud.get_primary_publication
							title = "#{primary.title} (#{primary.year.to_s})"
							bcTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s]
							# STYLE THE STUDY INFO
							for i in 0..2
								bcTab.row(j+2).set_format(i,formats['normal_wrap'])
							end
						end
						current_col = 3
					end
					# END NEW TAB CREATION
					#--------------------------------------------------------------------
					
					# ADD COLUMN TITLES
					bc_arms.each do |arm|
					  arm_title = arm.split("|+|+|+|")[0]
					  arm_desc = arm.split("|+|+|+|")[1]
					  title = "#{bc.question}::#{arm_title}"
					  bcTab.row(1).concat [title]
			    end
		    
				  # ADD STUDY DATA FOR EACH STUDY
				  row = 2
				  study_ids.each do |sid|
				  	col = current_col # GET WHATEVER THE CURRENT COLUMN IS
				  	bc_arms.each do |arm|
				  		arm_title = arm.split("|+|+|+|")[0].gsub(" ","")
				  		arm_desc = arm.split("|+|+|+|")[1]
							# DETERMINE IF THE CURRENT STUDY USES THIS ARM
			  			study_arm = 	Arm.where(:study_id=>sid,:extraction_form_id=>ef.id,:title=>arm_title,:description=>arm_desc).select("id")

							# IF THE STUDY USES THE ARM
							unless study_arm.empty? && arm_title != 'TOTAL'
					  		armID = study_arm.empty? ? 0 : study_arm.first.id
								# GET ANY DATA POINTS ASSOCIATED WITH THE QUESTION FOR THIS STUDY
					  		datapoint = BaselineCharacteristicDataPoint.where(:study_id=>sid,:extraction_form_id=>ef.id, :baseline_characteristic_field_id=>bc.id,:arm_id=>armID).select("value")
						  	# IF THE DATA POINT EXISTS
						  	unless datapoint.empty?
						  		val = datapoint.first.value
						  		# IF THE DATAPOINT HAS A VALUE
						  		unless val == ""
						  			bcTab[row,col] = val
						  		else
						  		# OTHERWISE, SAY THAT IT'S UNANSWERED
						  		  bcTab[row,col] = "---"
						  		end	
				  			else # AND if datapoint is empty
				  				arm_count = Arm.where(:study_id=>sid).count
			  					if arm_title == 'TOTAL' 
			  						if arm_count < 2
			  							bcTab[row,col] = arm_not_found
		  							end
			  					else
				  					bcTab[row,col] = "---"
				  				end
			  				end # END if num_arms > 0
			  			else	# END unless study_arm.empty?
			  				bcTab[row,col] = arm_not_found
			  			end
			  			col += 1
				  	end # END bc_arms.each do |arm|
				  	row += 1
				  end# END study_ids.each do |sid|

				  current_col = current_col + bc_arms.length
				else
					# OTHERWISE, IF IT'S A RADIO, CHECK BOX, SELECT
					#-----------------------------------------------
					bc_fields = bc.baseline_characteristic_fields # GET BC FIELDS
					subq_count = bc.baseline_characteristic_fields.where(:has_subquestion=>true).count
					
					# IF WE'RE GOING OVER THE COLUMN THRESHOLD FOR EXCEL, START A NEW TAB
					#--------------------------------------------------------------------
				  if current_col + (bc_arms.length * (bc_fields.length + subq_count)) > 250
				  	tabCount += 1
						bcTab = doc.create_worksheet :name => "Baseline Characteristics #{tabCount}"
						bcTab.row(1).concat ['PMID','Title (Year)','Author']
						
						# ADD STUDY TITLES AND AUTHORS
						#-----------------------------
						for j in 0..(study_ids.length - 1)
							stud = studies[j]
							primary = stud.get_primary_publication
							title = "#{primary.title} (#{primary.year.to_s})"
							bcTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s]
							# STYLE THE STUDY INFO
							for i in 0..2
								bcTab.row(j+2).set_format(i,formats['normal_wrap'])
							end
						end
						current_col = 3
					end
					# END NEW TAB CREATION
					#--------------------------------------------------------------------
					
					# ADD COLUMN TITLES
					#---------------------------------------------
					indeces = Hash.new
					arm_indeces = Hash.new
					col = current_col
					bc_arms.each do |arm| 	# FOR EACH ARM
						arm_title = arm.split("|+|+|+|")[0]
						bc_fields.each do |field| # FOR EACH FIELD
							title = "#{bc.question}::#{arm_title}::#{field.option_text}"
							if !arm_indeces.keys.include?("#{bc.question}::#{arm_title}")
								arm_indeces["#{bc.question}::#{arm_title}"] = []
							end
							bcTab[1,col] = title
							indeces[title] = col 
							arm_indeces["#{bc.question}::#{arm_title}"] << col
							col += 1
							if field.has_subquestion # ADD A SUBQUESTION IF IT EXISTS FOR THE FIELD
								bcTab[1,col] = "SUBQUESTION::#{field.subquestion}"
								col += 1 # INCREMENT THE COLUMN COUNTER
							end # END if field.has_subquestion
						end # END bc_fields.each do
					end # END bc_arms.each do 

					# DEFINE SOME VARIABLES FOR USE IN ENTERING DATA
					first_field = bc_fields.first.option_text # Gets the first field of the baseline characteristic
					first_arm = bc_arms.first.split("|+|+|+|")[0] # Gets the first arm in the table
					first_header = "#{bc.question}::#{first_arm}::#{first_field}" # The first column header
					first_col = indeces[first_header] # the first column for this baseline characteristic
					
					# the number of columns required by the baseline characteristic
					num_cols = bc_arms.length * (bc_fields.length + subq_count) - 1
					
					# ADD THE BC DATA POINTS FOR EACH STUDY
					#---------------------------------------------
					row = 2
					# FOR EACH STUDY 
					study_ids.each do |sid|
					  # GET DATA POINTS FOR THE STUDY
					  dps = BaselineCharacteristicDataPoint.where(:study_id=>sid, :baseline_characteristic_field_id=>bc.id, :extraction_form_id=>ef.id)
					  col_count = 0
					  unless dps.empty?
					  	dps.each do |dp|
					  	  # DETERMINE THE TITLE OF THE ARM FOR THIS DATA POINT
					  	  this_arm = (dp.arm_id==0) ? nil : Arm.find(dp.arm_id, :select=>["title"])

					  	  unless this_arm.nil? && dp.arm_id != 0
					  	  	# USE THE ARM TITLE TO DETERMINE WHAT COLUMN THE DATA SHOULD GO INTO
					  	  	this_arm_title = dp.arm_id==0 ? 'TOTAL' : this_arm.title
					  	  	this_title = "#{bc.question}::#{this_arm_title}::#{dp.value}"
					  	  	this_col = indeces[this_title]
					  	  	bcTab[row,this_col] = '1'
					  	  	if bcTab[1,this_col+1] =~ /^SUBQUESTION/
					  	  		bcTab[row,this_col+1] = dp.subquestion_value
					  	  	end
					  	  end
					  	end
					  	unless bc_fields.empty?
					  		for i in first_col..first_col+num_cols
					  			# IF NONE OF THESE CHOICES WERE SELECTED, MARK THEM WITH 0
					  			unless bcTab[row,i] =~ /[a-zA-Z1-9]+/ 
					  				if bcTab[1,i] =~ /^SUBQUESTION/
					  					bcTab[row,i] = 'n/a'
					  				else
					  					bcTab[row,i] = '0'
					  				end
					  			end
					  		end
					  	end
					  else
					  	# IF THERE ARE NO DATA POINTS, INDICATE THAT THE QUESTION REMAINS UNANSWERED
					  	unless bc_fields.empty?
					  		for i in first_col..first_col+num_cols
					  			bcTab[row,i] = '- unanswered -'
					  		end
					  	end
					  end
					  # SHOW ARMS THAT WERE NOT PRESENT IN THE STUDY
				  	sarms = Study.get_arms(sid)
				  	sarms = sarms.collect{|x| x.title}
				  	unless sarms.empty?
				  		for i in 0..sarms.length-1
				  			sarms[i] = "#{bc.question}::"+sarms[i]
				  		end
					  	
					  	arm_indeces.keys.each do |ai|
					  	  if ai == "#{bc.question}::TOTAL"
					  	  	if sarms.length < 2
					  	  		ais = arm_indeces[ai]
					  	  		ais.each do |j|
					  	  			bcTab[row,j] = arm_not_found
					  	  		end
					  	  		if bcTab[1,j+1] =~ /^SUBQUESTION/
					  	  			bcTab[row,j+1] = arm_not_found
					  	  		end
					  	  	end
					  	  elsif !sarms.include?(ai) && ai != "#{bc.question}::TOTAL"
					  	  	ais = arm_indeces[ai]
					  	  	ais.each do |j|
					  	  		bcTab[row,j] = arm_not_found
					  	  		if bcTab[1,j+1] =~ /^SUBQUESTION/
					  	  			bcTab[row,j+1] = arm_not_found
					  	  		end
					  	  	end
					  	  end
					  	end
					  end
					  row += 1
					end

					current_col = current_col + (bc_arms.length * (bc_fields.length + subq_count))
	  		end # END if bc.field_type...
			end # END bcs.each do |bc|
			# FORMAT THE WORKSHEET
			#----------------------------------
		  # FIRST, THE COL HEADERS
		  for i in 0..bcTab.column_count-1
	  		bcTab.row(1).set_format(i,formats['bold_centered'])
		  end
		  # COLUMN WIDTHS
		  # ASSIGN COLUMN WIDTHS
			bcTab.column(0).width=9
			bcTab.column(1).width=26
			bcTab.column(2).width=19
			for i in 2..bcTab.column_count-1
				bcTab.column(i).width=19
			end
			# NOW ALL OF THE ROW DATA...
			for i in 2..bcTab.last_row_index
				for j in 0..bcTab.column_count-1
					if j > 2
						bcTab.row(i).set_format(j,formats['row_data'])
					end
				end
				# ASSIGN ROW HEIGHTS
				bcTab.row(i).height = 40
			end
			bcTab.row(1).height=60
		end # END unless bcs.empty?		
	end #---------------- END get_baseline_characteristics ---------------#
	
	#----------------------------------------------------#
	# GET_QUALITY_DATA
	# SHOW QUALITY INFORMATION RELATED TO EACH STUDY IN THE PROJECT
	#----------------------------------------------------#
	def self.get_quality_data(doc,ef,studies,study_ids,formats)
		# TITLE INFORMATION
		qTab = doc.create_worksheet :name => "Study Quality"
		qTab.row(0).concat ['Study Quality']
		qTab.row(0).set_format(0, formats['section_title'])
		
		# GET QUALITY DIMENSION TITLES FOR THE EXTRACTION FORM
		dimensions = QualityDimensionField.where(:extraction_form_id=>ef.id).select(["id","title"])
		ratings = QualityRatingDataPoint.where(:study_id=>study_ids,:extraction_form_id=>ef.id)
		# IF RATINGS NOT EMPTY, FORM A HASH BY STUDY ID
		ratingsHash = Hash.new()
		unless ratings.empty?
			ratings.each do |r|
				ratingsHash[r.study_id] = [r.guideline_used,r.current_overall_rating,r.notes]
			end
		end
		
		unless dimensions.empty?
			# ADD STUDY TITLES AND AUTHORS
			#-----------------------------
			qTab.row(1).concat ['PMID','Title (Year)','Author']
			for i in 0..2
				qTab.row(1).set_format(i,formats['bold_centered'])
			end
			for j in 0..(study_ids.length - 1)
				stud = studies[j]
				primary = stud.get_primary_publication
				title = "#{primary.title} (#{primary.year.to_s})"
				qTab.row(j+2).concat [primary.pmid.to_s,title,primary.author.to_s]
				# STYLE THE STUDY INFO
				for i in 0..2
					qTab.row(j+2).set_format(i,formats['normal_wrap'])
				end
			end	
		
			# ADD COLUMN HEADERS, ONE FOR EACH TITLE
			col = 3
			indeces = Hash.new()
			dimensions.each do |d|
				qTab[1,col] = d.title
				qTab.row(1).set_format(col,formats['bold_centered'])
				col += 1
			end
			# ADD RATING COLUMNS
			qTab.row(1).concat ["Rating Guideline","Overall Rating","Notes"]
			qTab.row(1).set_format(col,formats['bold_centered'])
			qTab.row(1).set_format(col+1,formats['bold_centered'])
			qTab.row(1).set_format(col+2,formats['bold_centered'])
			
			
			# FILL IN THE COLUMN FOR EACH QUALITY DIMENSION
			row = 2						
			study_ids.each do |sid|
				col=3
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
				  for i in 3..3+dimensions.length - 1
				  	qTab[row,i] = '---'
				    qTab.row(row).set_format(i,formats['row_data'])
				  end
				end				
				qTab.row(row).height=40
				
				# ATTACH ANY QUALITY RATING DATA
				unless ratingsHash[sid].nil?
					arr = ratingsHash[sid]
					nextCol = dimensions.length + 3 
					for i in 0..2
						qTab[row,nextCol + i] = arr[i]
						qTab.row(row).set_format(nextCol+i,formats['row_data'])
					end
				else
					nextCol = dimensions.length + 3 
					for i in 0..2
						qTab[row,nextCol + i] = "---"
						qTab.row(row).set_format(nextCol+i,formats['row_data'])
					end
				end
				row += 1
			end
			# FORMAT STUDY HEADERS
			qTab.column(0).width = 9
			qTab.column(1).width = 26
			qTab.column(2).width = 19
			
			
			# APPLY COLUMN WIDTHS
			for i in 3..qTab.column_count - 2
				qTab.column(i).width=19
			end			
			qTab.column(qTab.column_count - 1).width = 25
		else # if !dimensions.empty?
			qTab.row(1).concat ["No Quality data was entered for studies in this project."]		
		end # END unless dimensions.empty?
	end # END get_quality_data
	def self.project_studies workbook
	end	
	
	def self.project_extraction_forms workbook
	end
end