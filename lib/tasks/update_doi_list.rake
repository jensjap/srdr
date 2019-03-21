require "rubyXL"
require "./lib/update_doi_list_helper"

desc "Updates DOI numbers from xlsx file."
task :update_doi_list, [:path_to_file] => :environment do |t, args|
  workbook = RubyXL::Parser.parse(args[:path_to_file])
  #workbook = RubyXL::Parser.parse("./lib/tasks/Minted_DOIs/SRDR-Projects-DOIs-2019-02-28.xlsx")
  ws1 = workbook[0]
  ws1.sheet_data[1..-1].each do |row|
    break unless row[0].present?

    project_title = row[0].value
    project_url   = row[1].value
    project_doi   = row[2].value

    project_id = /^https:\/\/srdr\.ahrq\.gov\/projects\/(\d+)$/.match(project_url)[1].to_i
    doi_id     = /^https:\/\/doi\.org\/(.+)$/.match(project_doi)[1]

    p = Project.find project_id
    #if project_title.strip == p.title.strip
    if true
      UpdateDoiListHelper.update_doi(p, doi_id)
    else
      puts "ERROR - Project title mismatch ID #{ p.id }:"
      puts "  Excel: #{ project_title }"
      puts "  In DB: #{ p.title }"
    end
  end
end
