# update the post_type in the comments table from NULL to reviewed.
namespace :add_completion_statuses do
	task :go => :environment do
		# find all studies
		s = Study.find(:all, :select=>["id"]).collect{|x| x.id}

		# get all StudyExtractionForm entries for the studies
		sefs = StudyExtractionForm.find(:all, :conditions=>["study_id IN (?)",s], :select=>["study_id","extraction_form_id"])
		efs = sefs.collect{|x| x.extraction_form_id}.uniq
		# for each unique extraction form 
		form_sections = Hash.new()
		
		# get extraction form included sections
		efs.each do |ef|
			# get the set of sections found in the form
			included_sections = ExtractionFormSection.find(:all, :conditions=>["extraction_form_id=? AND included=?",ef, true], :select=>["section_name"])
			unless included_sections.empty?
				form_sections[ef] = included_sections.collect{|x| x.section_name}
			else
				form_sections[ef] = []
			end		
			puts "DONE WITH EF: #{ef}\n"
			STDOUT.flush()
		end	
		# for each study
		s.each do |study|

			# determine if CompleteStudySection records have been created, and if not create them to be false
			exforms = sefs.select{|x| x.study_id == study}
			unless exforms.empty?
				exforms = exforms.collect{|x| x.extraction_form_id}
			else
				exforms = []
			end
			puts "FOUND FORMS #{exforms} for study #{study}\n\n"
			STDOUT.flush()

			exforms.each do |ef|
				sections = form_sections[ef]
				entered = CompleteStudySection.find(:all, :conditions=>["study_id = ? AND extraction_form_id = ?", study, ef], :select=>["section_name"])
				unless entered.empty?
					entered = entered.collect{|x| x.section_name}
				else
					entered = []
				end
				entries = 0
				sections.each do |sct|
					unless entered.include?(sct)
						CompleteStudySection.create(:study_id=>study, :extraction_form_id=>ef, :section_name=>sct, :is_complete=>false)
						entries += 1
					end
				end
				puts "Created #{entries} new entries for the study #{study} and ef #{ef}\n"
				STDOUT.flush()
			end
		end
	end
	
end
