# update the post_type in the comments table from NULL to reviewed.
namespace :give_teruhiko_studies do
	task :go => :environment do
		# find relevant studies currently assigned to admin
		# (the project id is 176)
		studies = Study.find(:all, :conditions=>["project_id=? AND creator_id=?",176,1],:select=>["id","creator_id"])
		studies.each do |s|
		# change assignment to Tarhiko
			s.creator_id = 90
			s.save
		# (his id is 90)
		end
		# -- done --
	end
	task :all => [:go]
end
