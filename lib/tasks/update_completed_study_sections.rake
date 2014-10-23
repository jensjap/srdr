# update the post_type in the comments table from NULL to reviewed.
namespace :update_completed_study_sections do
	task :go => :environment do
		# for each project in the database
		p = Project.find(:all, :select=>['id']).collect{|x| x.id}
		p.each do |pid|
			puts "---------- Project #{pid} ----------\n"
			# get associated extraction forms
			efs = ExtractionForm.find(:all, :conditions=>['project_id=?',pid], :select=>['id']).collect{|efr| efr.id}
			efs.each do |efid|
				# get associated sections 
				sections = ExtractionFormSection.find(:all, :conditions=>['extraction_form_id=? AND included=?',efid,true],:select=>['section_name']).collect{|se| se.section_name}
				sections = ['publications','questions'] + sections
				# get associated studies
				s = StudyExtractionForm.find(:all, :conditions=>['extraction_form_id=?',efid],:select=>['study_id']).collect{|sef| sef.study_id}
				# check the complete_study_sections table for entries
				s.each do |sid|
					sections.each do |sect|
						count = CompleteStudySection.count(:conditions=>['study_id=? AND extraction_form_id=? AND section_name=?',sid,efid,sect])
						# if none exist, create them and mark as false
						if count < 1
							puts "Creating a record:\n--> #{sect}, study #{sid}, ef #{efid}\n\n"
							STDOUT.flush()
							CompleteStudySection.create(:study_id=>sid,:extraction_form_id=>efid,:section_name=>sect,:is_complete=>false)
						end
						# if they do exist, do nothing
					end
				end
			end
		end
	end	
end
