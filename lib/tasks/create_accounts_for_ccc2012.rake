# update the post_type in the comments table from NULL to reviewed.
namespace :create_accounts_for_ccc2012 do
	task :go => :environment do
		admin = User.find(1)
		admin.user_type = 'super-admin'
		admin.save

		cochrane = Organization.create(:name=>"Cochrane Colloquium 2012")
		File.open("#{Rails.root.to_s}/lib/tasks/cochrane_accounts.txt").each_line do |line|
			fname, lname, login = line.split("|")
			login.gsub!(/\n/,"")
			puts "Creating account for #{fname} #{lname}: #{login}\n\n"
			STDOUT.flush()
			begin
			u = User.create(:login=>login, :email=>login, :fname=>fname, :lname=>lname, :organization=>'CCC2012', :user_type=>'member', :password=>'cochrane2012',:password_confirmation=>'cochrane2012')
			unless u.id.nil?
				UserOrganizationRole.create(:user_id=>u.id, :organization_id=>cochrane.id, :role=>"contributor", :status=>"VALID")
				UserProjectRole.create(:user_id=>u.id, :project_id=>59, :role=>'editor')
			end
			rescue Exception=>e
				puts "ERROR: #{e.message}\n#{e.backtrace}"
			end
		end
		for i in 1..20 do
			u = User.create(:login=>"cochrane#{i}",:email=>"cochrane#{i}@cochrane.nz", :fname=>"Cochrane",:lname=>"User #{i}", :user_type=>"member",:organization=>"CCC2012",:password=>"cochrane2012",:password_confirmation=>'cochrane2012')
			UserOrganizationRole.create(:user_id=>u.id, :organization_id=>cochrane.id, :role=>"contributor", :status=>"VALID")
			UserProjectRole.create(:user_id=>u.id, :project_id=>59, :role=>'editor')
			puts "Created account for user #{i}\n"
			STDOUT.flush()
		end
	end
	task :all => [:go]
end
