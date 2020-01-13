require "./lib/differentiate_arm_helper"

namespace :arms do
  # We need high accuracy here, so this will be slow but hopefully accurate.
  desc "Find all arms within a study extraction and ensure uniqueness of name."
  task :differentiate_names, [:project_id] => :environment do |t, args|
    project = Project.find args[:project_id]
    puts "Number of studies: #{ project.studies.length }"
    project.studies.each do |study|

      is_unique_arm_ids = DifferentiateArmHelper.check_for_arm_id_uniqueness(study.id)
      unless is_unique_arm_ids
        raise "FATAL ERROR: Study ID: #{ study.id } - Number of Arms: #{ study.arms.length } has non-unique arms"
      end

      is_unique_arm_titles = DifferentiateArmHelper.differentiate_arm_titles(study.id)
      unless is_unique_arm_titles
        puts "Study ID: #{ study.id } - Number of Arms: #{ study.arms.length }"
        puts "Arm titles are not unique!"
        puts "Arm ID - Arm Title - Arm Description:"
        study.arms.each do |arm|
          puts "#{ arm.id } - #{ arm.title } - #{ arm.description }"
        end
      end
    end
  end
end
