# update the post_type in the comments table from NULL to reviewed.
namespace :change_chris2_to_chrisparkin do
	task :update => :environment do
		User.update(15, :login=>"chrisparkin")
		
	end
	task :all => [:update]
end
