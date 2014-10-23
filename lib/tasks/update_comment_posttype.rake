# update the post_type in the comments table from NULL to reviewed.
namespace :update_comment_posttype do
	task :update => :environment do
		# find comments that have a null post_type
		comments = Comment.find(:all, :conditions=>["post_type IS NULL"])
		comments.each do |c|
			# update the post_type to REVIEWED and save
			c.post_type = "REVIEWED"
			c.save
		end
	end
	task :all => [:update]
end
