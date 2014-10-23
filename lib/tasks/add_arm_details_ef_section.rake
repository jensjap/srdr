# update the post_type in the comments table from NULL to reviewed.
namespace :add_arm_details_ef_section do
	task :create_arm_detail_sections => :environment do
		# get all extraction forms that have already been created
		efs = ExtractionFormSection.find(:all, :select=>"extraction_form_id");
		efs = efs.collect{|x| x.extraction_form_id}
		efs.uniq!

		efs.each do |efid|
			ExtractionFormSection.create(:extraction_form_id=>efid, :section_name=>"arm_details", :included=>true)
		end
	end
	task :create_outcome_detail_sections => :environment do
		# get all extraction forms that have already been created
		efs = ExtractionFormSection.find(:all, :select=>"extraction_form_id");
		efs = efs.collect{|x| x.extraction_form_id}
		efs.uniq!

		efs.each do |efid|
			ExtractionFormSection.create(:extraction_form_id=>efid, :section_name=>"outcome_details", :included=>true)
		end
	end
	task :all => [:create_arm_detail_sections, :create_outcome_detail_sections]
end
