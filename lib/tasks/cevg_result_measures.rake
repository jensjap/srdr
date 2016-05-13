# create an array of titles/descriptions for each measure
##############################################################
# DEFINE MEASURES FOR OUTCOMES
##############################################################
# Continuous
#-----------------------
continuous = ["How does the report say participants who withdrew or participants who did not complete the assessment (e.g. 'incomplete cases' or 'missing cases') were handled in this analysis?","How is this outcome described in this report?","The outcome is mentioned in the report, but quantitative results are not reported, specify how the result is described:","If adjusted, adjusted for:  ","N Analyzed ","Number of people (best guess)","Follow-up period in person-days ","Follow-up period in person-weeks ","Follow-up period in person-months ","Follow-up period in person-years ","Mean  ","Adjusted mean ","Least Squares Mean  ","Geometric Mean ","Log Mean ","Percent Change (mean) ","Percent Change (median) ","Standard Deviation ","Standard Error","95% Confidence Interval Lower Limit (95% LCI)","95% Confidence Interval Upper Limit (95% HCI)","90% Confidence Interval Lower Limit (90% LCI)","90% Confidence Interval Upper Limit (90% HCI)","Median","Mode","Max","Min","25th Percentile","75th Percentile"]

# Continuous Comparisons
continuous_comparison = ["How does the report say participants who withdrew or participants who did not complete the assessment (e.g. 'incomplete cases' or 'missing cases') were handled in this analysis?","How is this outcome described in this report?","Reported only 'statistically significant' or 'significant' without p value.  Specify how the result is described:","Reported only 'statistically non-significant' or 'non-significant' without p value.  Specify how the result is described:","Reported level of significance only (i.e. without other measures of effect).  Specify how the result is described: ","Threshold for p-value:","Operator for the p-value:","The outcome is mentioned in the report, but quantitative results are not reported, specify how the result is described:","If adjusted, adjusted for: ","Direction changed","N Analyzed","Number of people (best guess)","Follow-up period in person-days","Follow-up period in person-weeks","Follow-up period in person-months","Follow-up period in person-years","Mean","Adjusted mean","Least Squares Mean","Geometric Mean","Log Mean","Percent Change (mean)","Percent Change (median) ","Hedges g","Cohen's d","SMD (unspecified type)","Standard Deviation","Standard Error","95% Confidence Interval Lower Limit (95% LCI)","95% Confidence Interval Upper Limit (95% HCI)","90% Confidence Interval Lower Limit (90% LCI)","90% Confidence Interval Upper Limit (90% HCI)","Median","Mode","Max","Min","25th Percentile","75th Percentile","F-Value","Degrees of freedom","Chi2-Value","t-test","Tails","P-Value","Adj. P-Value"]

# Categorical
categorical = ["How does the report say participants who withdrew or participants who did not complete the assessment (e.g. 'incomplete cases' or 'missing cases') were handled in this analysis?","How is this outcome described in this report?","The outcome is mentioned in the report, but quantitative results are not reported, specify how the result is described:","If adjusted, adjusted for: ","N Analyzed","Number of people (best guess)","Follow-up period in person-days","Follow-up period in person-weeks","Follow-up period in person-months","Follow-up period in person-years","Events (count)","Non-events (count)","Proportion","Percentage","Rate","Standard Deviation","Standard Error","95% Confidence Interval Lower Limit (95% LCI)","95% Confidence Interval Upper Limit (95% HCI)","90% Confidence Interval Lower Limit (90% LCI)","90% Confidence Interval Upper Limit (90% HCI)"]

# Categorical Comparison
categorical_comparison = ["How does the report say participants who withdrew or participants who did not complete the assessment (e.g. 'incomplete cases' or 'missing cases') were handled in this analysis?","How is this outcome described in this report?","Reported only 'statistically significant' or 'significant' without p value.  Specify how the result is described:","Reported only 'statistically non-significant' or 'non-significant' without p value.  Specify how the result is described:","Reported level of significance only (i.e. without other measures of effect).  Specify how the result is described: ","Threshold for p-value:","Operator for the p-value:","The outcome is mentioned in the report, but quantitative results are not reported, specify how the result is described:","If adjusted, adjusted for: ","Direction changed","N Analyzed","Number of people (best guess)","Follow-up period in person-days","Follow-up period in person-weeks","Follow-up period in person-months","Follow-up period in person-years","Events (count)","Non-events (count)","Proportion","Percentage","Rate","Standard Deviation","Standard Error","95% Confidence Interval Lower Limit (95% LCI)","95% Confidence Interval Upper Limit (95% HCI)","90% Confidence Interval Lower Limit (90% LCI)","90% Confidence Interval Upper Limit (90% HCI)","Odds Ratio (OR)","Risk Ratio (RR)","Risk Difference (RD)","Number needed to treat (NNT)","Rate ratio","Rate difference","P-Value","Adj. Odds Ratio (OR)","Adj. Risk Ratio (RR)","Adj. Risk Difference (RD)","Adj. Number needed to treat (NNT)","Adj. Rate ratio","Adj. Rate difference","Adj. Standard Deviation","Adj. Standard Error","Adj. 95% Confidence Interval Lower Limit (95% LCI)","Adj. 95% Confidence Interval Upper Limit (95% HCI)","Adj. 90% Confidence Interval Lower Limit (90% LCI)","Adj. 90% Confidence Interval Upper Limit (90% HCI)","Adj. P-Value"]

survival_comparison = ["How does the report say participants who withdrew or participants who did not complete the assessment (e.g. 'incomplete cases' or 'missing cases') were handled in this analysis?","How is this outcome described in this report?","Reported only 'statistically significant' or 'significant' without p value.  Specify how the result is described:","Reported only 'statistically non-significant' or 'non-significant' without p value.  Specify how the result is described:","Reported level of significance only (i.e. without other measures of effect).  Specify how the result is described: ","Threshold for p-value:","Operator for the p-value:","The outcome is mentioned in the report, but quantitative results are not reported, specify how the result is described:","If adjusted, adjusted for: ","Direction changed","N Analyzed","Number of people (best guess)","Follow-up period in person-days","Follow-up period in person-weeks","Follow-up period in person-months","Follow-up period in person-years","Follow-up period per Kaplan Meier Estimates in person-days","Follow-up period per Kaplan Meier Estimates in person-weeks","Follow-up period per Kaplan Meier Estimates in person-months","Follow-up period per Kaplan Meier Estimates in person-years","Cumulative events (count)","Cumulative events per Kaplan Meier Estimates (count)","Non-events (count)","Non-events per Kaplan Meier Estimates (count)","Proportion with events","Proportion with events per Kaplan Meier Estimates","Percentage with events","Percentage with events per Kaplan Meier Estimates","Rate","Rate per Kaplan Meier Estimates","Standard Deviation","Standard Error","95% Confidence Interval Lower Limit (95% LCI)","95% Confidence Interval Upper Limit (95% HCI)","90% Confidence Interval Lower Limit (90% LCI)","90% Confidence Interval Upper Limit (90% HCI)","Hazard Ratio (HR)","Log Rank Statistic (Mantel-Cox test)","P-Value","Adj. Hazard Ratio (HR)","Adj. Standard Deviation","Adj. Standard Error","Adj. 95% Confidence Interval Lower Limit (95% LCI)","Adj. 95% Confidence Interval Upper Limit (95% HCI)","Adj. 90% Confidence Interval Lower Limit (90% LCI)","Adj. 90% Confidence Interval Upper Limit (90% HCI)","Adj. P-Value"]


##############################################################
# NOW CREATE THE APPROPRIATE RAKE TASKS
##############################################################
#------------------------------------------------------------ 
#
#---------------------------------------------------------       
namespace :cevg_result_measures do
  # CONTINUOUS OUTCOME MEASURES
  #--------------------------------------------
  desc "Create continuous measures"
  task :continuous => :environment do
      continuous.each do |title|
        print "."
        STDOUT.flush()
        DefaultCevgMeasure.create(:outcome_type => 'continuous', :title=>title, :is_default=>false, :results_type=>0)
      end
      continuous_comparison.each do |title|
        print "."
        STDOUT.flush()
        DefaultCevgMeasure.create(:outcome_type => 'continuous', :title=>title, :is_default=>false, :results_type=>1)
      end
  end

  desc "Create categorical measures"
  task :categorical => :environment do
      categorical.each do |title|
        print "."
        STDOUT.flush()
        DefaultCevgMeasure.create(:outcome_type => 'categorical', :title=>title, :is_default=>false, :results_type=>0)
      end
      categorical_comparison.each do |title|
        print "."
        STDOUT.flush()
        DefaultCevgMeasure.create(:outcome_type => 'categorical', :title=>title, :is_default=>false, :results_type=>1)
      end
  end

  desc "Create survival measures"
  task :survival => :environment do
      survival_comparison.each do |title|
        print "."
        STDOUT.flush()
        DefaultCevgMeasure.create(:outcome_type => 'survival', :title=>title, :is_default=>false, :results_type=>1)
      end
  end



  desc "Run all default_data tasks"
  task :all => [:continuous, :categorical, :survival]
end
