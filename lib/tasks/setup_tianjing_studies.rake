# update the post_type in the comments table from NULL to reviewed.
namespace :setup_tianjing_studies do
	
	task :create_all_studies => :environment do
		lineCount = 0
		user_map = Hash.new()
		tianjing = User.where(:login=>"tianjingli").first
		user_map["tianjing"] = tianjing.id
		File.open("#{Rails.root.to_s}/lib/tasks/tianjing_user_assignment.txt").each_line do |line|
			unless lineCount < 1
				splits = line.split("\t")
				username = splits[0]
				internalID = splits[1]
				author = splits[2].gsub("\"","")[0..250]
				title = splits[3].gsub("\"","")[0..250]
				journal = splits[4].gsub("\"","")[0..250]
				year = splits[6].gsub("\"","")[0..250]
				volume = splits[7].gsub("\"","")[0..250]
				issue = splits[8].gsub("\"","")[0..250]

				unless user_map.keys.include?(username.strip)
					if ['reviewer1','reviewer2'].include?(username.strip)
						tmpUser = User.create(:login => username.strip, :email => "reviewer"+username.strip.split("")[username.strip.length - 1]+"@testTuftsAccount.org", :fname => 'Test', :lname => 'Reviewer', :password => 'test', :password_confirmation => 'test', :organization => 'Johns Hopkins', :user_type => 'member')
						user_map[username.strip] = tmpUser.id
						UserOrganizationRole.create(:user_id=>tmpUser.id, :role=>"contributor",:status=>"VALID",:notify=>false,:add_internal_comments=>true,:view_internal_comments=>true,:publish=>false,:certified=>true,:organization_id=>1)
						UserProjectRole.create(:user_id=>tmpUser.id, :project_id=>95,:role=>'editor')

					else
						u = User.where(:login=>username.strip).first
						unless u.nil?
							user_map[username.strip] = u.id
						end
					end
				end
				tempS = Study.create(:project_id=>95, :creator_id=>user_map[username.strip])
				PrimaryPublication.create(:study_id=>tempS.id, :title=>"(#{internalID.to_s}) #{title}", :author=>author.to_s, :country=>"",:journal=>journal,:year=>year, :volume=>volume, :issue=>issue)
				StudyExtractionForm.create(:study_id=>tempS.id, :extraction_form_id=>120)
				StudyKeyQuestion.create(:study_id=>tempS.id, :key_question_id=>244, :extraction_form_id=>120)
				print "Set up Study: #{title}\n\n"
				STDOUT.flush()
			end
			lineCount += 1
		end
	end

	task :all => [:create_all_studies]
end
