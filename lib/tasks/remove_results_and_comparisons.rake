# DELETE ALL DEFAULT OUTCOME MEASURES AND COMPARISON MEASURES
##############################################################
#------------------------------------------------------------	
#
#---------------------------------------------------------			 
namespace :remove_results_and_comparisons do
	desc "results"
  task :outcome_data_entries => :environment do
		OutcomeDataEntry.delete_all(["study_id=?",1])
	end
	
	desc "comparisons"
  task :outcome_comparisons => :environment do
		Comparison.delete_all(["study_id=?",1])
	end
	
  desc "remove both outcome data entries and comparisons"
  task :all => [:outcome_data_entries, :outcome_comparisons]
end

