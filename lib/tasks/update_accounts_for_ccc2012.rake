# update the post_type in the comments table from NULL to reviewed.
namespace :update_accounts_for_ccc2012 do
	task :go => :environment do

		File.open("#{Rails.root.to_s}/lib/tasks/cochrane_accounts.txt").each_line do |line|
			fname, lname, login = line.split("|")
			login.gsub!(/\n/,"")
			puts "Updating account for #{fname} #{lname}: #{login}\n\n"
			STDOUT.flush()
			begin
			u = User.find(:first, :conditions=>["fname=? AND lname=? AND login=?",fname, lname, login], :select=>["id"])
			unless u.nil?
				role = UserProjectRole.find(:first, :conditions=>["user_id=? AND project_id=?",u.id, 59])
				unless role.nil?
					role.project_id = 175
					role.save
					puts "Updated the role for #{login}\n"
					STDOUT.flush()
				end
			end
			rescue Exception=>e
				puts "ERROR: #{e.message}\n#{e.backtrace}"
			end
		end
		for i in 1..20 do
			u = User.find(:first, :conditions=>["login=? AND email=?", "cochrane#{i}", "cochrane#{i}@cochrane.nz"])
			unless u.nil?
				UserProjectRole.destroy(:conditions=>["user_id=? AND project_id=?", u.id, 59])
				puts "Destroyed the user role for project 59 for user #{u.login}\n"
				STDOUT.flush()
			end
		end
	end
	task :all => [:go]
end
