# update the post_type in the comments table from NULL to reviewed.
namespace :remove_arms_tab_for_ef233 do
	task :update => :environment do
		# find comments that have a null post_type
		section_entry = ExtractionFormSection.find(:first, :conditions=>["extraction_form_id=? AND section_name=?",233,'arms'])
		unless section_entry.nil?
			section_entry.included = false
			section_entry.save
		end
	end
	task :all => [:update]
end
