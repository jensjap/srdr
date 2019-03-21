module UpdateDoiListHelper
  def self.update_doi(project, new_doi_id)
    if project.doi_id.present?
      #puts "WARNING - Existing DOI found for Project ID #{ project.id }"
      #puts "  Existing DOI ID: '#{ project.doi_id }'"
      #puts "  System did not update with '#{ new_doi_id }'"

      return
    end
    project.doi_id = new_doi_id
    project.save

    puts "Project ID #{ project.id } now has DOI ID: '#{ project.doi_id }'"
  end
end
