# update the post_type in the comments table from NULL to reviewed.
namespace :create_ef_section_options do
	task :go => :environment do
		# get a list of extraction form ids

		ActiveRecord::Base.establish_connection('production') #UNCOMMENT THIS FOR DEVELOPMENT
		
		efs = ExtractionForm.find(:all, :select=>["id"])
		efs = efs.collect{|ef| ef.id}.uniq
		# get a list of sections included in these extraction forms
		included_sections = ExtractionFormSection.find(:all, :conditions=>["section_name IN (?) AND extraction_form_id IN (?) AND included = ?",["arm_details","outcome_details"], efs, true],
													:select=>["extraction_form_id","section_name","included"])
		# for each extraction form
		efs.each do |efid|
			# variables to represent by arm and by outcome
			by_arm = false
			by_outcome = false
			
			# if the form uses either section arm_details or outcome_details
			if included_sections.count{|s| s.extraction_form_id == efid} > 0
=begin
				# see if any arm details have been saved to an arm_id other than 0
				# if yes, then they use by_arm in arm_detail. if no, then they do not use by_arm

				datapoints_by_arm = ArmDetailDataPoint.count(:conditions=>["extraction_form_id = ? AND arm_id > ?", efid, 0])
				
				if datapoints_by_arm > 0
					by_arm = true
				end
=end
				# the outcome_detail section by_outcome row will always be false
				# since they haven't had the ability until now	
				EfSectionOption.create(:extraction_form_id=>efid, :section=>'arm_detail', :by_arm=>true)
				EfSectionOption.create(:extraction_form_id=>efid, :section=>'outcome_detail', :by_outcome=>false)
			end
		end
	end
	task :all => [:go]
end
