namespace :project_stats_for_daa_report do
  task :go => :environment do
    puts "\"project creator\",\"project id\",\"project title\",\"created at\",\"updated at\",\"published at\",\"# Users in Project\",\"# KQ in Project\",\"# EF in Project\",\"# Studies in Project\",\"Publication Status\""
    Project.all.each do |p|
      puts "\"#{ User.find(p.creator_id).login }\",\"#{ p.id }\",\"#{ p.title }\",\"#{ p.created_at }\",\"#{ p.updated_at }\",\"#{ p.publication_requested_at }\",\"#{ p.users.count }\",\"#{ p.key_questions.count }\",\"#{ p.extraction_forms.count }\",\"#{ p.studies.count}\",\"#{ p.is_public ? 'Y' : 'N' }\""
    end
  end

  task :all => [:go]
end
