# update the post_type in the comments table from NULL to reviewed.
namespace :create_accounts_for_GIN_2016 do
  desc "Create user accounts for the GIN conference 2016"
	task :go => :environment do
		admin = User.find(1)
		admin.user_type = 'super-admin'
		admin.save

		gin = Organization.create(:name=>"Gin Conference 2016")
		for i in 1..50 do
			u = User.create(:login=>"gin#{i}",:email=>"gin#{i}@gin.com", :fname=>"Gin",:lname=>"User #{i}", :user_type=>"member",:organization=>"GIN2016",:password=>"password",:password_confirmation=>'password')
			UserOrganizationRole.create(:user_id=>u.id, :organization_id=>gin.id, :role=>"contributor", :status=>"VALID")
			#UserProjectRole.create(:user_id=>u.id, :project_id=>59, :role=>'editor')
			puts "Created account for user #{i}\n"
			STDOUT.flush()
		end
	end
	task :all => [:go]
end
