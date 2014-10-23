# update the post_type in the comments table from NULL to reviewed.
namespace :setup_environmental_studies do
	
	task :create_all_studies => :environment do
		begin
			removed_count = 0
			incorrect = Study.find(:all, :conditions=>["project_id = ?",176], :select=>["id"])
			incorrect.each do |inc|
				inc.destroy()
				removed_count += 1
			end

			lineCount = 0
			user_map = Hash.new()
			File.open("#{Rails.root.to_s}/lib/tasks/tracking_file_175.txt").each_line do |line|
				unless lineCount < 1
					splits = line.split("\t")
					userID = splits[14]
					internalID = splits[0]
					author = splits[7].gsub("\"","")[0..250]
					title = splits[5].gsub("\"","")[0..250]
					journal = splits[6].gsub("\"","")[0..250]
					pubmedID = splits[2].gsub("\"","")[0..250]
					year = ""
					volume = ""
					issue = ""
					tempS = Study.create(:project_id=>176, :creator_id=>userID)
					tempPP = PrimaryPublication.create(:study_id=>tempS.id, :title=>title, :author=>author, :pmid=>pubmedID, :country=>"", :journal=>journal, :year=>year, :volume=>volume, :issue=>issue)
					PrimaryPublicationNumber.create(:primary_publication_id=>tempPP.id, :number=>internalID.to_s, :number_type=>"internal")	
					StudyExtractionForm.create(:study_id=>tempS.id, :extraction_form_id=>233)
					StudyKeyQuestion.create(:study_id=>tempS.id, :extraction_form_id=>233, :key_question_id=>452)
					#puts "INFO IS:\nUSER: #{userID}\nINTERNAL ID: #{internalID}\nAUTHOR: #{author}\nTITLE: #{title}\n\n"
					puts "Set up study: #{title}\n\n"
					STDOUT.flush()
				else
					puts "FOUND THE FIRST LINE\n\n"
				end
				lineCount += 1
			end
			puts "REMOVED #{removed_count} studies before we began.\n\n"
		rescue Exception=>e
			puts "CAUGHT EXCEPTION: #{e.message}\n\n#{e.backtrace}\n\n"
		end
	end
	task :all => [:create_all_studies]
end
