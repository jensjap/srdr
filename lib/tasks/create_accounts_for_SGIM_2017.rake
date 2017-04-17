# update the post_type in the comments table from NULL to reviewed.
namespace :create_accounts_for_SGIM_2017 do
  desc "Create user accounts for the SGIM conference 2017"
	task :go => :environment do
#		admin = User.find(1)
#		admin.user_type = 'super-admin'
#		admin.save

		sgim = Organization.create(:name=>"SGIM Conference 2017")
		for i in 1..50 do
      u = User.create!(:login=>"SGIM#{i}",:email=>"sgim#{i}@sgim.com", :fname=>"SGIM",:lname=>"User #{i}", :user_type=>"member",:organization=>sgim,:password=>"password",:password_confirmation=>'password')
      UserOrganizationRole.create(:user_id=>u.id, :organization_id=>sgim.id, :role=>"contributor", :status=>"VALID")
			UserProjectRole.create(:user_id=>u.id, :project_id=>1120, :role=>'editor')
			puts "Created account for user #{i}\n"
			STDOUT.flush()
		end
	end
	task :all => [:go]
end
