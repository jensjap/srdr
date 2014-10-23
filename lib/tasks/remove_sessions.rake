# update the post_type in the comments table from NULL to reviewed.
namespace :remove_sessions do
	
	task :all => :environment do
		s = Session.find(:all)
		s.each do |obj|
			obj.destroy
		end
	end
	
end
