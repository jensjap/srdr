# update the post_type in the comments table from NULL to reviewed.
namespace :setup_internal_ids_for_tianjing do
	
	task :touch_all_studies => :environment do
		project_id = 95
		
		studies = Study.where(:project_id=>95)
		# for each study in the project
		studies.each do |s|
			# get the title and strip out the internal ID
			primPub = s.get_primary_publication
			# if there is a publication record for the study
			unless primPub.nil?
				title = primPub.title
				unless primPub.title.nil?
					if title.match(/^\(.*\)\s/)
						# create a primary publication number and remove it from the title
						edgeL = title.index(/^\(/)
						edgeR = title.index(/\)/)
						num = title[edgeL+1..edgeR-1]
						PrimaryPublicationNumber.create(:primary_publication_id=>primPub.id, :number=>num, :number_type=>'internal')
						primPub.title = title.gsub(/\(.*\)\s/,"")
						# save the updated publication information
						primPub.save
					end
				else
					PrimaryPublicationNumber.create(:primary_publication_id=>primPub.id, :number=>"Not Entered", :number_type=>'internal')
				end
			end
		end
	end
	task :all => [:touch_all_studies]
end
