# DELETE ALL DEFAULT OUTCOME MEASURES AND COMPARISON MEASURES
##############################################################
#------------------------------------------------------------	
#
#---------------------------------------------------------			 
namespace :remove_default_measures do
	desc "remove outcome measures"
  task :outcome_measures => :environment do
		DefaultOutcomeMeasure.delete_all
	end
	
	desc "remove comparison measures"
  task :comparison_measures => :environment do
    DefaultComparisonMeasure.delete_all
  end
	
  desc "remove both outcome and comparison measures"
  task :all => [:outcome_measures, :comparison_measures]
end

