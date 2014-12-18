# create an array of titles/descriptions for each measure
##############################################################
# DEFINE MEASURES FOR OUTCOMES
##############################################################

# CONTINUOUS DATA
#-----------------------------------------------------------
# CENTRAL TENDENCY
#-----------------------------------------------------------
continuous = [["Unit",""],
							["Value",""],
							["N Enrolled","The number of patients originally enrolled"],
							["N Analyzed","The number of patients analyzed"],
							["Mean",""],
							["Median",""],
							["SD","Standard Deviation"],
							["SE","Standard Error"],
							["Least Squares Mean",""],
							["Geometric Mean",""],
							["Log Mean",""],
						 ]
continuous_defaults = ["N Analyzed", "Mean", "SD", "SE"]


#-----------------------------------------------------------
# DISPERSION
#-----------------------------------------------------------								 
continuous_dispersion = [["Mode",""],
												 ["Max",""],
												 ["Min",""],
												 ["95% CI low",""],
											   ["95% CI high",""],
											   ["90% CI low",""],
											   ["90% CI high",""],
											   ["25th Percentile",""],
											   ["75th Percentile",""],
												]
	
# CATEGORICAL DATA
#-----------------------------------------------------------								
categorical = [["N Enrolled","The number of patients originally enrolled"],
							["N Analyzed","The number of patients analyzed"],
							["Counts",""],
							["Proportion",""],
							["Percentage",""],
							["Incidence (per 1000)",""],
							["Incidence (per 100,000)",""]
						 ]
categorical_defaults = ["N Enrolled", "Counts"]		
	 
# SURVIVAL DATA
#-----------------------------------------------------------								
survival = [["N Enrolled","The number of patients originally enrolled"],
							["N Analyzed","The number of patients analyzed"],
							["Counts",""],
							["Proportions",""],
							["Percentage",""],
							["SD",""],
						  ["SE",""],
						  ["95% CI low",""],
						  ["95% CI high",""],
						  ["90% CI low",""],
						  ["90% CI high",""],
						  ["Follow-up in person-years (raw data)",""],
						  ["Annual Rate as per Raw Data",""],
						  ["Events per Kaplan Meier estimates",""],
						  ["Follow-up in person-years per Kaplan Meier estimates",""],
						  ["Annual Rate as per Kaplan Meier estimates",""],
						  ["Log Rank Statistic",""],
						  ["Log Rank P-Value",""],
						  ["Hazard Ratio (HR)",""],
						  ["Follow-up Mean",""],
							["Follow-up Median",""],
							["Follow-up Range",""],
							["Event X/N",""]						  
						 ]
survival_defaults = ["N Enrolled", "Counts", "SD"]


##############################################################
# DEFINE MEASURES FOR COMPARISONS
##############################################################
# For now within-arm and between-arm remain the same, but this will likely change in the future
#
# CONTINUOUS COMPARISONS
#------------------------------------------------------
continuous_bac = [["N Enrolled","The number of patients originally enrolled"],
										["N Analyzed","The number of patients analyzed"],
										["Mean Difference",""],
										["Mean Difference (Net)",""],
										["Median Difference",""],
										["Median Difference (Net)",""],
										["SD",""],
										["SE",""],
										["95% CI low",""],
						  			["95% CI high",""],
									  ["90% CI low",""],
									  ["90% CI high",""],
									  ["P-Value",""],
									  ["Statistical Test:",""],
									  ["Adjusted For:",""]
								  ]

continuous_wac = [["N Enrolled","The number of patients originally enrolled"],
										["N Analyzed","The number of patients analyzed"],
										["Mean Difference",""],
										["Mean Difference (Net)",""],
										["Median Difference",""],
										["Median Difference (Net)",""],
										["SD",""],
										["SE",""],
										["95% CI low",""],
									  ["95% CI high",""],
									  ["90% CI low",""],
									  ["90% CI high",""],
									  ["P-Value",""],
									  ["Statistical Test:",""],
									  ["Adjusted For:",""]
								  ]
continuous_wac_defaults = ["N Analyzed","Mean Difference","SE"]
continuous_bac_defaults = ["Mean Difference (Net)","SE","P-Value"]	            
# CATEGORICAL COMPARISONS
#------------------------------------------------------
categorical_bac = [["Statistical Test:","The type of test used"],
									["Odds Ratio (OR)","Unadjusted Odds Ratio"],
									["Risk Ratio (RR)","Unadjusted Risk Ratio"],
									["Risk Difference (RD)","Unadjusted Risk Difference"],
									["SD",""],
									["SE",""],
									["95% CI low",""],
								  ["95% CI high",""],
								  ["90% CI low",""],
								  ["90% CI high",""],
								  ["P-Value",""]
							  ]
categorical_adj_bac = [["Adj. Odds Ratio (OR)","Adjusted Odds Ratio"],
											["Adj. Risk Ratio (RR)","Adjusted Risk Ratio"],
											["Adj. Risk Difference (RD)","Adjusted Risk Difference"],
											["Adj. SD","Adjusted SD"],
											["Adj. SE"," Adjusted SE"],
											["Adj. 95% CI low",""],
										  ["Adj. 95% CI high",""],
										  ["Adj. 90% CI low",""],
										  ["Adj. 90% CI high",""],
										  ["Adj. P-Value",""],
										  ["Adjusted For:",""]
									  ]

categorical_wac = [["SD",""],
									["SE",""],
									["95% CI low",""],
								  ["95% CI high",""],
								  ["90% CI low",""],
								  ["90% CI high",""],
								  ["P-Value",""],
								  ["Absolute Change",""],
								  ["% Change",""]
							  ]
categorical_adj_wac = [["Adj. SD","Adjusted SD"],
											["Adj. SE"," Adjusted SE"],
											["Adj. 95% CI low",""],
										  ["Adj. 95% CI high",""],
										  ["Adj. 90% CI low",""],
										  ["Adj. 90% CI high",""],
										  ["Adj. P-Value",""],
										  ["Adjusted For:",""]
									  ]			
categorical_wac_defaults = ["Absolute Change","% Change"]
categorical_bac_defaults = ["Odds Ratio (OR)","SE","95% CI low","95% CI high","P-Value"]

# SURVIVAL COMPARISONS
#-----------------------------------------------------------								
survival_bac = [["N Enrolled","The number of patients originally enrolled"],
							["N Analyzed","The number of patients analyzed"],
							["Counts",""],
							["Proportions",""],
							["Percentage",""],
							["SD",""],
						  ["SE",""],
						  ["95% CI low",""],
						  ["95% CI high",""],
						  ["90% CI low",""],
						  ["90% CI high",""],
						  ["Follow-up in person-years (raw data)",""],
						  ["Annual Rate as per Raw Data",""],
						  ["Events per Kaplan Meier estimates",""],
						  ["Follow-up in person-years per Kaplan Meier estimates",""],
						  ["Annual Rate as per Kaplan Meier estimates",""],
						  ["Log Rank Statistic",""],
						  ["Log Rank P-Value",""],
						  ["Hazard Ratio (HR)",""],
						  ["Follow-up Mean",""],
							["Follow-up Median",""],
							["Follow-up Range",""],
							["Event X/N",""]						  
						 ]
survival_bac_defaults = ["Hazard Ratio (HR)", "SE", "SD", "95% CI low","95% CI high"]

# DIAGNOSTIC COMPARISONS
#-----------------------------------------------------------	
# DESCRIPTIVE VALUES
#-----------------------------------------------------------------
diagnostic_descriptive = [['# of participants recruited','# of participants recruited to receive the diagnostic tests'],
			  ['# not receiving index test','The number of participants that did not receive the index test.'],
			  ['# not receiving reference test','The number of participants that did not receive the reference test.'],
			  ['% of participants recruited','The percentage of participants recruited to receive the diagnostic tests'],
			  ['% not receiving index test','The percentage of participants that did not receive the index test.'],
			  ['% not receiving reference test','The percentage of participants that did not receive the reference test.']
			  ]	
diagnostic_descriptive_defaults = ['# of participants recruited','# not receiving index test','# not receiving reference test']								
# ASSUMING REFERENCE STANDARD
diagnostic_assuming_reference = [["2x2 Table","The standard 2x2 table"],
				  ["Sensitivity (%)","Sensitivity (%)"],
				  ["Sensitivity 95% LCI","95% Confidence Interval Lower Limit for Sensitivity"],
				  ["Sensitivity 95% HCI","95% Confidence Interval Upper Limit for Sensitivity"],
				  ["Specificity (%)","Specificity (%)"],
				  ["Specificity 95% LCI","95% Confidence Interval Lower Limit for Specificity"],
				  ["Specificity 95% HCI","95% Confidence Interval Upper Limit for Specificity"],
				  ["ROC - AUC","Receiver Operating Characteristic - Area Under Curve"],
				  ["ROC (AUC) +/- SD","Receiver Operating Characteristic - Area Under Curve Plus/Minus SD"],
				  ["ROC (AUC) P-Value","Receiver Operating Characteristic - Area Under Curve P-Value"],

				 ]
diagnostic_assuming_reference_defaults = ["2x2 Table","Sensitivity (%)","Sensitivity 95% LCI","Sensitivity 95% HCI",
										"Specificity (%)","Specificity 95% LCI","Specificity 95% HCI"]

# ADDITIONAL ANALYSIS
diagnostic_additional_analysis = [["Hazard Ratio (HR)","Unadjusted Hazard Ratio"],
									["Risk Ratio (RR)","Unadjusted Risk Ratio"],
									["Odds Ratio (OR)","Unadjusted Odds Ratio"],
									["Univariate (Y/N)","Univariate (Y/N)"],
									["95% LCI","95% Confidence Interval Lower Limit"],
								  	["95% HCI","95% Confidence Interval Upper Limit"],
								  	["P-Value","P-Value"],
								  	["Adj. Hazard Ratio (HR)","Unadjusted Hazard Ratio"],
									["Adj. Risk Ratio (RR)","Unadjusted Risk Ratio"],
									["Adj. Odds Ratio (OR)","Unadjusted Odds Ratio"],
									["Adj. 95% LCI","Adjusted 95% Confidence Interval Lower Limit"],
								  	["Adj. 95% HCI","Adjusted 95% Confidence Interval Upper Limit"],
								  	["Adj. P-Value","Adjusted P-Value"],
								  	["If multivariate model, list covariates in model","If multivariate model, list covariates in model"]
								   ]
diagnostic_additional_analysis_defaults = ["Odds Ratio (OR)","95% LCI","95% HCI","P-Value"]

##############################################################
# NOW CREATE THE APPROPRIATE RAKE TASKS
##############################################################
#------------------------------------------------------------	
#
#---------------------------------------------------------			 
namespace :default_result_measures do
	# CONTINUOUS OUTCOME MEASURES
	#--------------------------------------------
    desc "Create continuous measures"
    task :default_continuous => :environment do
  	  	continuous.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = continuous_defaults.include?(title)
			
			DefaultOutcomeMeasure.create(:outcome_type => 'continuous', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1)
		end
		# dispersion values
		continuous_dispersion.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = continuous_defaults.include?(title)
			
			DefaultOutcomeMeasure.create(:outcome_type => 'continuous', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 2)
		end
		print "done.\n\n"
		STDOUT.flush()
  	end
  
    # CATEGORICAL OUTCOME MEASURES
	#--------------------------------------------
    desc "Create categorical outcome measures"
    task :default_categorical => :environment do
  		print "Starting categorical outcome measures..."
  		categorical.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = categorical_defaults.include?(title)
			
			DefaultOutcomeMeasure.create(:outcome_type => "categorical", :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1)
		end
		print "done.\n\n"
		STDOUT.flush()
    end
  
    # CONTINUOUS OUTCOME COMPARISON MEASURES
	#--------------------------------------------
    desc "Create within-arm and between-arm comparison measures for continuous outcomes"
    task :default_continuous_comparisons => :environment do
   		# within-arm comparisons = 0, between-arm = 1
  		print "Starting comparison_measures for continuous outcomes"
		# between-arm
  		continuous_bac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = continuous_bac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'continuous', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1, 
																	 :within_or_between=>1)	
		end
		# within-arm
		continuous_wac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = continuous_wac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'continuous', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1, 
																	 :within_or_between=>0)	
		end
		print "done.\n\n"
		STDOUT.flush()
	end
	
	# CATEGORICAL OUTCOME COMPARISON MEASURES
	#--------------------------------------------
	desc "Create within-arm and between-arm comparison measures for categorical outcomes"
    task :default_categorical_comparisons => :environment do
  		# within-arm comparisons = 0, between-arm = 1
  		print "Starting comparison_measures for categorical outcomes"
		# BETWEEN-ARM
		#-----------------------------------------------------
  		categorical_bac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = categorical_bac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'categorical', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1, 
																	 :within_or_between=>1)	
		end
		categorical_adj_bac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = categorical_bac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'categorical', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 2, 
																	 :within_or_between=>1)	
		end
		
		# WITHIN-ARM
		#-----------------------------------------------------
		categorical_wac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = categorical_bac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'categorical', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 1, 
																	 :within_or_between=>0)	
		end
		categorical_adj_wac.each do |title,desc|
			print "."
			STDOUT.flush()
			is_default = categorical_bac_defaults.include?(title)
			DefaultComparisonMeasure.create(:outcome_type=>'categorical', :title=>title, :description=>desc, 
																	 :unit=>"", :is_default=>is_default, :measure_type => 2, 
																	 :within_or_between=>0)	
		end
		
		print "done.\n\n"
		STDOUT.flush()
	end
	# SURVIVAL OUTCOME AND COMPARISON MEASURES
	#-----------------------------------------
	desc "Create measures and bac comparison measures for survival outcomes"
    task :default_survival_measures => :environment do
  		print "\n\nStarting outcome_measures for survival outcomes"
  		# start with the raw data measures
  		survival.each do |title,desc|
	  		print "."
	  		STDOUT.flush()
	  		is_default = survival_defaults.include?(title)
	  		DefaultOutcomeMeasure.create(:outcome_type=>'survival',:title=>title,:description=>desc,
	  									 :unit=>'',:is_default=>is_default,:measure_type=>1)
  		end
  	
	  	# now for the comparison measures (between-arm only)
	  	print "\n\nStarting outcome_measures for survival comparisons\n"
	  	# start with the raw data measures
	  	survival_bac.each do |title,desc|
	  		print "."
	  		STDOUT.flush()
	  		is_default = survival_bac_defaults.include?(title)
	  		DefaultComparisonMeasure.create(:outcome_type=>'survival',:title=>title,:description=>desc,
	  										:unit=>'',:is_default=>is_default,:measure_type=>1,:within_or_between=>1)
	  	end
  	end
  	# DIAGNOSTIC TEST COMPARISON MEASURES
	#-----------------------------------------
	desc "Create measures and diagnostic test outcome "
  	task :diagnostic_comparison_measures => :environment do
	  	print "\n\nStarting comparison_measures for diagnostic test outcomes"
	  	# ALL DESCRIPTIVE MEASURES ARE BETWEEN-ARM COMPARISON MEASURES
	  	# BUT THEY ARE SPLIT INTO THREE GROUPS: DESCRIPTIVE, ASSUMING REFERENCE AND ADDITIONAL ANALYSIS
	  	puts "\n\nStarting descriptive measures" 
	  	diagnostic_descriptive.each do |title,desc|
	  		print "."
	  		STDOUT.flush()
	  		is_default = diagnostic_descriptive_defaults.include?(title)
	  		DefaultComparisonMeasure.create(:outcome_type=>'diagnostic_1',:title=>title,:description=>desc,
	  																	:unit=>'',:is_default=>is_default,:measure_type=>1,:within_or_between=>1)
		end  	
		puts "\n\nStarting reference measures"
		diagnostic_assuming_reference.each do |title,desc|
	  		print "."
	  		STDOUT.flush()
	  		is_default = diagnostic_assuming_reference_defaults.include?(title)
	  		DefaultComparisonMeasure.create(:outcome_type=>'diagnostic_2',:title=>title,:description=>desc,
	  																	:unit=>'',:is_default=>is_default,:measure_type=>1,:within_or_between=>1)
		end  	
		puts "\n\nStarting additional measures"
		diagnostic_additional_analysis.each do |title,desc|
	  		print "."
	  		STDOUT.flush()
	  		is_default = diagnostic_additional_analysis_defaults.include?(title)
	  		DefaultComparisonMeasure.create(:outcome_type=>'diagnostic_3',:title=>title,:description=>desc,
	  																	:unit=>'',:is_default=>is_default,:measure_type=>1,:within_or_between=>1)
		end 
	end 	
	
	desc "Run all default_data tasks"
	task :all => [:default_continuous, :default_categorical, :default_continuous_comparisons, :default_categorical_comparisons,:default_survival_measures, :diagnostic_comparison_measures]
end
