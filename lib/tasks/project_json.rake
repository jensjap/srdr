require 'json'
require 'tasks/helpers/export_helper'

namespace :project_json do
  desc "Creates a json export of the given project"
  task export_projects: :environment do
    #projects = nil
    if ENV['pids'].present?
      pids = ENV['pids'].split(",")
      projects = Project.where(id: pids)
    else
      projects = Project.all
    end

    #logger = ActiveSupport::Logger.new(Rails.root.join('tmp','json_exports','logs', 'export_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    projects_count = projects.length

    #logger.info "Task started at #{start_time}"

    projects.each.with_index do |project, index|
      puts "#{Time.now.to_s} - Processing Project ID #{project.id}"

      av = ActionView::Base.new(Rails.root.join('app', 'views', 'projects'))

      wrapped_project = ExportHelper::ProjectWrapper.new project

      project_json_content = av.render 'export.json', project: wrapped_project

      #if not project_json_content.empty?
      #  logger.info "#{index}/#{projects_count} - project_id: #{project.id}"
      #else
      #  logger.info "#{index}/#{projects_count} - project_id: #{project.id} - errors: #{project_json_content.errors}"
      #end

      file_folder  = Rails.root.join('tmp','json_exports','projects')
      #file = File.read(file_folder.join(file_name + ".json"))
      #fields = JSON.parse(form)
      #updated_fields = set_fields(fields)
      File.open(file_folder.join("project_" + project.id.to_s + ".json"), "w+") do |f|
        f.truncate 0
        f.puts project_json_content
      end
      if File.read(file_folder.join("project_" + project.id.to_s + ".json")).length > 0
        puts "#{Time.now.to_s} - JSON successfully written: tmp/json_exports/projects/project_" + project.id.to_s + ".json"
      end
    end
    end_time = Time.now
    duration = (end_time - start_time) / 1.minute
    #logger.info "Task finished at #{end_time} and last #{duration} minutes."
    #logger.close
  end
end

