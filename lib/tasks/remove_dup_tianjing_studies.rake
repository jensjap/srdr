# update the post_type in the comments table from NULL to reviewed.
namespace :remove_dup_tianjing_studies do
	
    task :remove_dup_studies => :environment do
        dup_studies = Study.find(:all, :conditions=>["project_id = 95 and created_at >= '2012-06-29 22:21' and created_at < '2012-06-29 22:23'"])
        dup_studies.each do |study|
            puts "........... removing duplicate study "+study.id.to_s
            pubs = PrimaryPublication.find(:first, :conditions=>["study_id = ?",study.id])
            pubs.destroy
            ef = StudyExtractionForm.find(:first, :conditions=>["study_id = ? and extraction_form_id = 120",study.id])
            ef.destroy
            kq = StudyKeyQuestion.find(:first, :conditions=>["study_id = ? and extraction_form_id = 120 and key_question_id = 244",study.id])
            kq.destroy
            study.destroy
        end
        puts "............ removed "+dup_studies.size.to_s
     end
     task :all => [:remove_dup_studies]
end
