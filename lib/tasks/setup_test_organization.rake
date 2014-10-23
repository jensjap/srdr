# update the post_type in the comments table from NULL to reviewed.
namespace :setup_test_organization do
	@orgID = nil
	task :create_organization => :environment do
		# create a testing organization
		orgo = Organization.create(:name=>'The Terrific Tufts Test Team', :description=>'ALL users on the DEV site.', :contact_name=>"Chris Parkin",:contact=>"cparkin@tuftsmedicalcenter.org");
		@orgID = orgo.id
	end

	task :setup_user_roles do
		# find all users in the dev site and assign them a spot in the test organization
		all_users = User.find(:all)
		all_users.each do |u|
			UserOrganizationRole.create(:user_id=>u.id, :role=>"contributor", :status=>"VALID", :notify=>false, :add_internal_comments=>true, :view_internal_comments=>true, :publish=>false, :certified=>true, :organization_id=>@orgID)
		end

	end
	task :all => [:create_organization, :setup_user_roles]
end
