TZ = 'Eastern Time (US & Canada)'

namespace :tianjing_tasks do
  desc "Find out who changed what and when."
  task :create_edit_log => :environment do
  	project = Project.where(title: 'AAO - Reliability of systematic reviews on interventions for cataract')[0]
  	project_last_updated_at = project.updated_at

  	puts 'question text, study id, value, updated at'

    tables = ActiveRecord::Base.connection.tables
    tables.each do |table_name|
      case table_name
      when /.*data_points$/
      	_get_last_updated_data_points(table_name)
      end
    end

  	#p project_last_updated_at.in_time_zone(TZ)
  end

  desc "user_log"
  task :user_log => :environment do
  	puts 'username, email, last login at'
  	project = Project.where(title: 'AAO - Reliability of systematic reviews on interventions for cataract')[0]
  	project.users.each do |user|
  	  puts "\"#{ user.login }\", \"#{ user.email }\", \"#{ user.last_login_at.in_time_zone(TZ) }\""
  	end
  end

  task :all => [:create_edit_log]
end

def _get_last_updated_data_points(table_name)
  model = table_name.singularize.camelize

  case model
  when 'BaselineCharacteristicSubcategoryDataPoint', 'DesignDetailSubcategoryDataPoint'

  when 'ComparisonDataPoint', 'OutcomeDataPoint', 'RegistryDataPoint'

  else
    data_points = model.constantize.where("updated_at > ?", 1.week.ago)
    data_points.each do |dp|
      if dp.try(:study).try(:project).id.eql?(1658)
        puts "\"#{ dp.design_detail.question }\", \"#{ dp.study.id }\", \"#{ dp.value }\", \"#{ dp.updated_at.in_time_zone(TZ) }\""
      end
    end
  end
end