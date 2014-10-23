# Create an example prostate study under the admin account
namespace :create_prostate_project do
	# create the variables that we'll build on
	project,ef,kq1,kq2,kq3 = nil                                         # proj / extraction form / key questions
	dd1,dd2,dd3,dd4,dd5,dd6,dd7,dd8,dd9,dd10,dd11 = nil                  # design details
	bc1,bc2,bc3,bc4,bc5,bc6,bc7,bc8,bc9,bc10,bc11,bc12,bc13,bc14 = nil   # baseline characteristics
	qd1,qd2,qd3,qd4,qd5,qd6,qd7,qd8,qd9,qd10 = nil                       # quality dimensions 
	study,arm1,arm2,oc1,oc2 = nil                                        # study / arms / outcomes
	# ------ START BY CREATING THE PROJECT ---- #
	#-------------------------------------------#
	desc "Create the project"
	task :create_project => :environment do
		title = "Prostate Cancer 2009"
		description = "Background: Radiation therapy is one of many treatment options for patients with prostate cancer.\n\nPurpose: To update findings about the clinical and biochemical outcomes of radiation therapies for localized prostate cancer.\n\nData Sources: MEDLINE (2007 through 3/2011) and the Cochrane Library (through 3/2011).\n\nStudy Selection: Published English-language comparative studies involving adults with localized prostate cancer who either underwent first line radiation therapy or received no initial treatment.\n\nData Extraction: 6 researchers extracted information on study design, potential bias, sample characteristics, interventions, outcomes, and rated the strength of overall evidence. Data for each study were extracted by one reviewer and confirmed by another."
		funding_source = "The Agency for Healthcare Research and Quality, U.S. Department of Health and Human Services (Contract No. 290 2007 10055 I)."
		notes = "None."
		
		project = Project.create(:title=>title, :description=>description, :funding_source=>funding_source, :creator_id=>1, :is_public=>true)
		UserProjectRole.create(:user_id=>1,:project_id=>project.id,:role=>'lead')
	end
	
	# ------ CREATE THE KEY QUESTIONS --------#
	#-----------------------------------------#
	desc "Create the key questions"
	task :create_key_questions => :environment do
	
		q1 = "What are the benefits and harms of radiation therapy for clinically localized prostate cancer compared to watchful waiting (including active surveillance) in terms of clinical outcomes?"
		q2 = "What are the benefits and harms of different forms of radiation therapy for clinically localized prostate cancer in terms of clinical outcomes? The comparisons of interest are between the following radiation modalities: stereotactic body radiation therapy (SBRT, including CyberKnife therapy), classically fractionated external beam radiation therapy (EBRT, including 3D-conformal radiation therapy, intensity modulated radiation therapy, and particle therapy), high dose rate brachytherapy (HDR), and low dose rate brachytherapy (LDR). These modalities will be specifically compared with each other, i.e., SBRT vs. EBRT, SBRT vs. HDR, SBRT vs.LDR, EBRT vs. HDR, EBRT vs. LDR, and HDR vs. LDR."
		q3 = "How do specific patient characteristics, e.g., age, race/ethnicity, presence or absence of comorbidities, preferences (e.g., tradeoff of treatment-related adverse effects vs. potential for disease progression) affect the outcomes of these different forms of radiation therapy?"
		kq1 = KeyQuestion.create(:project_id=>project.id, :question_number=>1, :question=>q1)
		kq2 = KeyQuestion.create(:project_id=>project.id, :question_number=>2, :question=>q2)
		kq3 = KeyQuestion.create(:project_id=>project.id, :question_number=>3, :question=>q3)
	end
		
	# ------ CREATE THE EXTRACTION FORM ------#
	#-----------------------------------------#
	desc "Create the extraction form"
	task :create_extraction_form => :environment do
		# the ef
		title = "Prostate cancer EF for RCTs"
		ef = ExtractionForm.create(:title => title, :creator_id=>1, :adverse_event_display_arms=>true, :adverse_event_display_total=>true, :project_id=>project.id)
		
		# extraction form key questions
		ExtractionFormKeyQuestion.create(:extraction_form_id=>ef.id, :key_question_id=>kq1.id)
		ExtractionFormKeyQuestion.create(:extraction_form_id=>ef.id, :key_question_id=>kq2.id)
		ExtractionFormKeyQuestion.create(:extraction_form_id=>ef.id, :key_question_id=>kq3.id)
		
		# extraction form arms
		ef_arms = [["70.2 GyE","50.4 Gy (standard) + 19.8 Gy (proton boost)"],
							 ["79.2 GyE","50.4 Gy (standard) + 28.8 Gy (proton boost)"]]
		ef_arms.each do |arm|
			ExtractionFormArm.create(:name=>arm[0], :description=>arm[1], :extraction_form_id=>ef.id)
		end
		
		# extraction form outcome names
		ef_outcomes = [["Biochemical failure","Definition: ASTRO","Categorical"],
									 ["Overall survival","","Continuous"],
									 ["GI Toxicity","","Continuous"],
									 ["GU Toxicity","","Continuous"]
								  ]
		ef_outcomes.each do |efoc|
			ExtractionFormOutcomeName.create(:title=>efoc[0],:note=>efoc[1],:extraction_form_id=>ef.id,:outcome_type=>efoc[2])
		end
								 
		# Extraction Form Sections
		# first define the ones that are not included by default
		["questions","publications"].each do |section|
			ExtractionFormSection.create(:extraction_form_id=>ef.id, :section_name=>section, :included=>false)
		end
		
		# then define the ones that are included
		["arms","design","baselines","outcomes","results","adverse","quality"].each do |section|
			ExtractionFormSection.create(:extraction_form_id=>ef.id, :section_name=>section, :included=>true)
		end
		
		# create the adverse event columns
		["Timeframe","Is Event Serious?","Definition of Serious","Number Affected","Number at Risk"].each do |title|
			AdverseEventColumn.create(:name=>title,:description=>"Created by Default", :extraction_form_id=>ef.id)
		end
		
		# create the quality dimension fields
		["Appropriate Randomization Technique (y/n/nd/NA)","Allocation concealment [Y, N, Nd, NA]",
		"Appropriate Washout Period (y/n/nd/NA)","Dropout rate <20 percent [Y, N]",
		"Blinded outcome assessment [Y, N, Nd]","Intention to treat analysis [Y, N, Nd]",
		"Appropriate statistical analysis [Y, N]","Assessment for Confounding (y/n/nd/NA)",
		"Clear reporting with no discrepancies [Y, N]"].each_with_index do |title,index|
		  var = "qd" + (index+1).to_s
			eval("#{var} = QualityDimensionField.create(:title=>title,:extraction_form_id=>ef.id)")   	
	  end
		
		# create the quality rating fields
		QualityRatingField.create(:extraction_form_id=>ef.id,:rating_item=>"Good",:display_number=>1)
		QualityRatingField.create(:extraction_form_id=>ef.id,:rating_item=>"Fair",:display_number=>2)
		QualityRatingField.create(:extraction_form_id=>ef.id,:rating_item=>"Poor",:display_number=>3)
	end
	
	# ------ CREATE THE EXTRACTION FORM DESIGN DETAILS AND FIELDS ------#
	#-------------------------------------------------------------------#
  desc "Create the extraction form design details"
	task :create_design_details => :environment do
		# create an array of arrays to describe the design detail and all of it's fields
		questions = [["Country","select"], ["Multi-Centered?","radio"],
		             ["Enrollment years","radio"], ["Study Design","select"],
		             ["Study Region","checkbox"],["Trial or Cohort Name Inclusion","text"],
		             ["Race/Ethnicity","checkbox"],["Inclusion","text"],
		             ["Exclusion","text"], ["N Enrolled","text"],
		             ["N Analyzed","text"]
							 ]
		questions.each_with_index do |q,index|
		  var = "dd" + (index+1).to_s
		  qnum = index + 1
		  eval("#{var} = DesignDetail.create(:question=>q[0], :extraction_form_id=>ef.id, :field_type=>q[1],
		  																	 :question_number=>qnum)")
		end		
		
    # create choice options for each question defined
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"USA", :subquestion=>"population", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"Israel", :subquestion=>"population", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"Canada", :subquestion=>"population", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"France", :subquestion=>"population", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"No Data", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd1.id, :option_text=>"Other", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd2.id, :option_text=>"Yes", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd2.id, :option_text=>"No", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd3.id, :option_text=>"1960-1970", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd3.id, :option_text=>"1971-1980", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd3.id, :option_text=>"1981-1990", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd3.id, :option_text=>"1991-2000", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd3.id, :option_text=>"2001-2010", :subquestion=>"", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"RCT", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"Prospective Cohort", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"Cross-Sectional", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"Case Control", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"Retrospective Cohort", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd4.id, :option_text=>"Other", :subquestion=>"Please specify", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"North America", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"South America", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"Europe", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"Asia", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"Africa", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd5.id, :option_text=>"Australia", :has_subquestion=>false)
    DesignDetailField.create(:design_detail_id=>dd7.id, :option_text=>"White", :subquestion=>"%", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd7.id, :option_text=>"Black", :subquestion=>"%", :has_subquestion=>true)
    DesignDetailField.create(:design_detail_id=>dd7.id, :option_text=>"Hispanic", :subquestion=>"%", :has_subquestion=>true)
  end
  
  # ------ CREATE THE EXTRACTION FORM BASELINE CHARACTERISTIC FIELDS ------#
	#------------------------------------------------------------------------#
  desc "Create the extraction form baseline characteristics"
	task :create_baseline_characteristics => :environment do
		# create an array of arrays to describe the design detail and all of it's fields
		questions = [["N","text"],["Mean age (SD),yr","text"],
								 ["PSA (ng/mL) (SD)","text"],["Gleason Score (SD)","text"],
								 ["ADT","text"],["D'Amico (DA);NCCN;define if other","select"],
								 ["Risk Level","checkbox"],["T level","checkbox"],
								 ["Immobilization Technique","text"],["Planning Algorithm","text"],
								 ["Total Dose (Gy)","text"],["Dose per fraction (Gy)","text"],
								 ["Duration","text"],["Applied margins for PTV","text"]
							  ]
								
		questions.each_with_index do |q,index|
			var = "bc" + (index+1).to_s
			eval ("#{var}=BaselineCharacteristic.create(:question=>q[0],:extraction_form_id=>ef.id,
																									:field_type=>q[1],:question_number=>(index+1))")
		end
    
    
    # create choice options for each question defined
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc5.id, :option_text=>"Yes", :has_subquestion=>false)
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc5.id, :option_text=>"No", :has_subquestion=>false)
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc6.id, 
    																	 :option_text=>"D'Amico (DA)", :has_subquestion=>false)
	  BaselineCharacteristicField.create(:baseline_characteristic_id=>bc6.id, 
	 																		:option_text=>"NCCN", :has_subquestion=>false)
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc6.id, 
	 																		:option_text=>"Other", :subquestion=>"", :has_subquestion=>true)
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc7.id, 
	 																		:option_text=>"low risk", :subquestion=>"%", :has_subquestion=>true)								
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc7.id, 
	 																		:option_text=>"intermediate risk", :subquestion=>"%", :has_subquestion=>true)
	 	BaselineCharacteristicField.create(:baseline_characteristic_id=>bc7.id, 
	 																		:option_text=>"high risk", :subquestion=>"%", :has_subquestion=>true)
	 	BaselineCharacteristicField.create(:baseline_characteristic_id=>bc8.id, 
	 																		:option_text=>"T1", :subquestion=>"%", :has_subquestion=>true)								
    BaselineCharacteristicField.create(:baseline_characteristic_id=>bc8.id, 
	 																		:option_text=>"T2", :subquestion=>"%", :has_subquestion=>true)
	 	BaselineCharacteristicField.create(:baseline_characteristic_id=>bc8.id, 
	 																		:option_text=>"T3 or T4", :subquestion=>"%", :has_subquestion=>true)
		BaselineCharacteristicField.create(:baseline_characteristic_id=>bc8.id, 
	 																		:option_text=>"Tx", :subquestion=>"%", :has_subquestion=>true)								
  end
  
  # ------      CREATE THE STUDY         ---- #
	#-------------------------------------------#
	desc "Create the Study"
	task :create_study => :environment do
		# the study object
		study = Study.create(:project_id=>project.id, :creator_id=>1)
		
		# set up the key questions and extraction forms
		StudyKeyQuestion.create(:study_id=>study.id, :key_question_id=>kq1.id,:extraction_form_id=>ef.id)
		StudyKeyQuestion.create(:study_id=>study.id, :key_question_id=>kq2.id,:extraction_form_id=>ef.id)
		
		# set up the study extraction forms
		StudyExtractionForm.create(:study_id=>study.id, :extraction_form_id=>ef.id)
		
		# set up the primary publication
		pmid = "20124169"
		title = "Randomized trial comparing conventional-dose with high-dose conformal radiation therapy in early-stage adenocarcinoma of the prostate: long-term results from proton radiation oncology group/american college of radiology 95-09."
		author = "Zietman AL., Bae K., Slater JD., Shipley WU., Efstathiou JA., Coen JJ., Bush DA., Lunt M., Spiegel DY., Skowronski R., Jabola BR., Rossi CJ."
		affiliation = "Department of Radiation Oncology, Cox 3, Massachusetts General Hospital, Boston MA 02114, USA. azietman@partners.org"
		journal = "Journal of clinical oncology : official journal of the American Society of Clinical Oncology"
		year = "2010"
		vol = "28"
		issue = "7"
		PrimaryPublication.create(:study_id=>study.id, :title=>title, :author=>author, :country=>affiliation,
															:year=>year, :journal=>journal, :pmid=>pmid, :volume=>vol, :issue=>issue)
		
		# set up study arms
		[["70.2 GyE","50.4 Gy (standard) + 19.8 Gy (proton boost)"],
		 ["79.2 GyE","50.4 Gy (standard) + 28.8 Gy (proton boost)"]].each_with_index do |arm,index|
		 	var = "arm"+(index+1).to_s
		  eval("#{var} = Arm.create(:study_id=>study.id, :title=>arm[0], :description=>arm[1], :display_number=>(index+1),
		  					 :extraction_form_id=>ef.id,:is_suggested_by_admin=>false,:is_intention_to_treat=>true)")
		 	 	
	  end
	  
	  # set up study outcomes
	  o1 = ["Biochemical Failure",true,"Categorical","Definition: ASTRO"]
	  o2 = ["GI Toxicity",true,"Continuous"]
	  [o1,o2].each_with_index do |o,index|
	  	var = "oc"+(index+1).to_s
	  	eval("#{var}=Outcome.create(:study_id=>study.id,:title=>o[0],:is_primary=>o[1],:outcome_type=>o[2], 
	  								 :description=>o[3], :extraction_form_id=>ef.id)")
	  end
	  # set up outcome timepoints for the studies I just created
	  # for the first outcome...
	  [[5,"years"],[10,"years"]].each do |tp|
	  	OutcomeTimepoint.create(:outcome_id=>oc1.id, :number=>tp[0],:time_unit=>tp[1])
	  end
	  
	  # for the second outcome...
	  ["Acute","Delay"].each do |tp|
	  	OutcomeTimepoint.create(:outcome_id=>oc2.id,:time_unit=>tp)
	  end
	  # set up outcome subroups for the studies I just created
	  # For now just use default "All Participants"
	  OutcomeSubgroup.create(:outcome_id=>oc1.id, :title=>"All Participants",:description=>"All Participants")
	  OutcomeSubgroup.create(:outcome_id=>oc2.id,:title=>"All Participants",:description=>"All Participants")

	  
	  # set up the quality dimension data points
	  dimensions = ["No Data","No Data","N/A","Yes","No Data","Yes","Yes","Yes","N/A"]
	  for i in 1..9 do
	  	qdid = eval("qd"+(i.to_s)).id
	  	QualityDimensionDataPoint.create(:quality_dimension_field_id=>qdid,:value=>dimensions[i-1],:study_id=>study.id,
	  																	 :extraction_form_id=>ef.id)
	  end
	  
	  # set up the quality rating data point
	  QualityRatingDataPoint.create(:study_id=>study.id, :guideline_used=>"EPC",:current_overall_rating=>"Good",
	  															:extraction_form_id=>ef.id)
	end
	
	# ------   CREATE THE DESIGN DETAIL DATAPOINTS   ---- #
	#-----------------------------------------------------#
	desc "create the design detail data points for each question"
	task :create_dd_data_points => :environment do
	  # set up design detail data points
	  # for each of the questions saved
	  answers = [[["USA","300,000,000"]],"Yes","1981-1990","RCT","North America","na",[["White","90"],
	  					["Black","4"],["Hispanic","3"]],
	  					"men with stage T1b through T2b tumors; PSA <15 ng/mL; no evidence of metastatic disease",
	  					"nd","393","392"]
	  for i in 1..11
	  	tmpAnswer = answers[i-1]
	  	ddid = eval("dd"+i.to_s).id
	  	if tmpAnswer.class == String
	  		DesignDetailDataPoint.create(:design_detail_field_id=>ddid, :value=>tmpAnswer, :study_id=>study.id,
	  																 :extraction_form_id=>ef.id)
	  	elsif tmpAnswer.class == Array
	  		tmpAnswer.each do |x|
	  			ans = x[0]
	  			sq = x[1]
	  			DesignDetailDataPoint.create(:design_detail_field_id=>ddid, :value=>ans, :study_id=>study.id,
	  																 :extraction_form_id=>ef.id,:subquestion_value=>sq)
	  		end
	  	end
	  end
	end  
	# ------   CREATE THE BASELINE CHARACTERISTIC DATAPOINTS   ---- #
	#---------------------------------------------------------------#
	desc "create the baseline characteristic data points for each question"
	task :create_bc_data_points => :environment do
	  # set up baseline characteristic data points
	  # for each of the questions saved
	  arm1_answers = ["196","67","<5: 28% 5-10: 58% 10-15: 14%","2-6 75% 7 15% 8-10 9%","Yes",
	  [["Other","DA"]], [["low risk","56"],["intermediate risk","35"],["high risk","9"]],
	  [["T1","62"],["T2","38"],["T3 or T4","0"],["Tx","nd"]],"casts of thermal plastic or body foam",
	  "nd","nd","1.8 GyE (booster)","nd","0.5 cm"]
	  arm2_answers = ["195","66","<5: 24% 5-10: 61% 10-15: 15%","2-6 75% 7 15% 8-10 8%","No",
	  [["Other","DA"]], [["low risk","60"],["intermediate risk","31"],["high risk","8"]],
	  [["T1","61"],["T2","39"],["T3 or T4","0"],["Tx","nd"]],"casts of thermal plastic or body foam",
	  "nd","nd","1.8 GyE (booster)","nd","0.5 cm"]
	  arm_ids = [arm1.id,arm2.id]
	  for i in 1..14
	  	tmpAnswer1 = arm1_answers[i-1]
	  	tmpAnswer2 = arm2_answers[i-1]
	  	bcid = eval("bc"+i.to_s).id
	  	[tmpAnswer1,tmpAnswer2].each_with_index do |tmpAnswer,index|
	  		armid = arm_ids[index]
		  	if tmpAnswer.class == String
		  		BaselineCharacteristicDataPoint.create(:baseline_characteristic_field_id=>bcid, :value=>tmpAnswer, :study_id=>study.id,
		  																 :extraction_form_id=>ef.id,:arm_id=>armid)
		  	elsif tmpAnswer.class == Array
		  		tmpAnswer.each do |x|
		  			ans = x[0]
		  			sq = x[1]
		  			BaselineCharacteristicDataPoint.create(:baseline_characteristic_field_id=>bcid, :value=>ans, :study_id=>study.id,
		  																 :extraction_form_id=>ef.id,:subquestion_val=>sq,:arm_id=>armid)
		  		end
		  	end
		  end
	  end
	end
		
	#-------- RUN ALL TASKS -------#
	desc "Run all prostate project tasks"
  task :all => [:create_project, :create_key_questions, :create_extraction_form, 
  							:create_design_details, :create_baseline_characteristics, :create_study,
  							:create_dd_data_points, :create_bc_data_points
							 ]
end
