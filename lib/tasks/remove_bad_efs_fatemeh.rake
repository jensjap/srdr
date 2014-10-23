# there are some extraction forms potentially causing problems in fatemeh's project. Remove them!
namespace :remove_bad_efs_fatemeh do
	
	task :all => :environment do
		sefs = StudyExtractionForm.where(:extraction_form_id=>[174,175])
		sefs.each do |s|
			s.destroy
		end
		ExtractionForm.destroy(174)
		ExtractionForm.destroy(175)
	end
	
end
