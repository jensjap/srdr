# update the post_type in the comments table from NULL to reviewed.
namespace :add_kqs_and_pubs_to_completion_statuses do
	task :go => :environment do
		begin
		# start by getting all complete study section entries
		all_entries = CompleteStudySection.find(:all, :select=>["study_id","extraction_form_id","section_name"])

		# get all unique study ids
		all_studies = all_entries.collect{|x| x.study_id}.uniq

		# for each study 
		all_studies.each do |s|

			# for each extraction form associated with the study
			study_entries = all_entries.select{|stud| stud.study_id == s}
			extraction_forms = study_entries.collect{|se| se.extraction_form_id}.uniq
			extraction_forms.each do |ef|

				# determine if there are publication and key question entries for complete_study_section
				# if there is already, do nothing. Otherwise, create them and set them to 'true'
				kq_entry = all_entries.find{|kq| kq.study_id == s && kq.extraction_form_id == ef && kq.section_name == 'questions'}
				pub_entry = all_entries.find{|pub| pub.study_id == s && pub.extraction_form_id == ef && pub.section_name == 'publications'}
				if kq_entry.nil?
					CompleteStudySection.create(:study_id=>s, :extraction_form_id=>ef, :section_name=>'questions', :is_complete=>true)
					puts "Created a questions entry for study #{s} and ef #{ef}\n"
				end
				if pub_entry.nil?
					CompleteStudySection.create(:study_id=>s, :extraction_form_id=>ef, :section_name=>'publications', :is_complete=>true)
					puts "Created a publications entry for study #{s} and ef #{ef}\n"
				end
				
				STDOUT.flush()
			end
		end
		rescue Exception=>e 
  			puts "ERROR: #{e.message}\n#{e.backtrace}\n\n"
		end
	end	
end
