##############################################################
# NOW CREATE THE APPROPRIATE RAKE TASKS
##############################################################
#------------------------------------------------------------ 
#
#---------------------------------------------------------       
namespace :add_cevg_percent_change do
  # CONTINUOUS OUTCOME MEASURES
  #--------------------------------------------
  task :continuous => :environment do
    efs = ExtractionForm.find(:all, :conditions=>["project_id = ?",427], :select=>["id"]).collect{|x| x.id}
    puts "EFS: #{efs.join(', ')}"
    outcomes = Outcome.find(:all, :conditions => ["extraction_form_id IN (?) AND outcome_type = ?", efs, 'Continuous'])
    ocdes = OutcomeDataEntry.find(:all, :conditions => ["outcome_id IN (?)", outcomes.collect{|x| x.id}])
    comparisons = Comparison.find(:all, :conditions => ["outcome_id IN (?)", outcomes.collect{|x| x.id}])
    puts "Found #{ocdes.length} OCDES and #{comparisons.length} comparisons"

    ocdes.each do |ocde|
      puts "Creating measure for ocde #{ocde.id}."
      OutcomeMeasure.create(:outcome_data_entry_id => ocde.id, :title => 'Percent Change (mean)')
    end

    comparisons.each do |comp|
      puts "Creating measure for comp #{comp.id}."
      ComparisonMeasure.create(:comparison_id => comp.id, :title => 'Percent Change (mean)')
    end
  end
  desc "Run all default_data tasks"
  task :all => [:continuous]
end
