# update the post_type in the comments table from NULL to reviewed.
namespace :add_missing_outcome_detail_efsections do
	task :go => :environment do
		# get all extraction forms that have already been created
		efs = ExtractionFormSection.find(:all, :select=>"extraction_form_id");
		efs = efs.collect{|x| x.extraction_form_id}
		efs.uniq!

		# for each of the extraction forms found
		efs.each do |efid|
			# determine if an entry was made for outcome details and if not, create one
			entry = ExtractionFormSection.where(:extraction_form_id=>efid, :section_name=>"outcome_details").count
			if entry == 0
				ExtractionFormSection.create(:extraction_form_id=>efid, :section_name=>"outcome_details", :included=>true)
			end
		end
	end
	
	task :all => [:go]
end
