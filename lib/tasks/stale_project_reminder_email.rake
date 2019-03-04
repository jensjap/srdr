namespace :stale_project_reminder_email do
  desc "Scan projects and find any that fit success criteria.

  Success criteria are:
  1. Project has not been published
  2. Project has not been modified in 6 months
  3. Project lead has not opted out of emails for specific project"
  task :go => :environment do
    recipients = Hash.new  # recipients = { 'email': Reminder }

    unpublished_projects = Project.where("(is_public=? OR is_public IS ?) AND updated_at < ?", 0, nil, 6.month.ago).order(:updated_at)
    unpublished_projects.each do |project|
      project.lead_users.each do |leader|
        if recipients[leader.email]
          reminder = recipients[leader.email]
        else
          reminder = Reminder.new(leader.email)
          recipients[leader.email] = reminder
        end

        unless opted_out_of_email_reminder(leader, project)
          reminder.add_project_to_reminder(project)
        end
      end
    end

    recipients.each do |recipient_email, reminder|
      if recipient_email == 'jensjap@gmail.com'
        StaleProjectReminderEmail.send_reminder(recipient_email, reminder.projects.keys).deliver
#      elsif recipient_email == 'srdr@ahrq.hhs.gov'
#        StaleProjectReminderEmail.send_reminder(recipient_email, reminder.projects.keys).deliver
#      elsif recipient_email == 'isaldanh@jhsph.edu'
#        StaleProjectReminderEmail.send_reminder(recipient_email, reminder.projects.keys).deliver
      end
    end
  end

  task :all => [:go]
end

def opted_out_of_email_reminder(user, project)
  return false
end

class Reminder
  attr_accessor :projects

  def initialize(email)
    @email = email
    @projects = Hash.new  # @projects = { project_id: Project }
  end

  def add_project_to_reminder(project)
    @projects[project.id] = project
  end
end
