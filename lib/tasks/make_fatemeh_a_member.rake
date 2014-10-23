# update the post_type in the comments table from NULL to reviewed.
namespace :make_fatemeh_a_member do
	task :go => :environment do
		u = User.find(45)
		u.user_type = 'member'
		u.save	
	end
end