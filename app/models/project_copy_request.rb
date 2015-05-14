class ProjectCopyRequest < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :project_id, presence: true
end