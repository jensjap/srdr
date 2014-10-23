# update the post_type in the comments table from NULL to reviewed.
namespace :remove_account do
	task :remove => :environment do
		User.destroy(19);
	end
	task :all => [:remove]
end