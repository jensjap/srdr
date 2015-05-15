class ProjectCopyRequest < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :project_id, presence: true

  def to_s
    if self.include_data == true 
      return "Extraction Forms Only"
    elsif self.include_studies == true 
      return "Extraction Forms & Study List"
    elsif self.include_forms == true
      return "Extraction Forms, Studies & Extracted Data"
    else
      return "--"
    end
  end
end