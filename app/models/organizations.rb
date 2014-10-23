# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  description  :text
#  created_at   :datetime
#  updated_at   :datetime
#  contact_name :string(255)
#  contact      :string(255)
#

class Organizations < ActiveRecord::Base

  # for user, return organization object
  # @param user [User]
  # @return organization
  def self.get_user_organization(current_user)
    if !current_user.nil?
      organizations = Organizations.where(:name => current_user.organization)
      organization = organizations.first
      return organization
    end
  end

  # get the user's role within the Organization
  # @param [user_id] current_user.id
  # @return organization role
  def self.get_user_organization_role(user_id)
    user = User.find(user_id)
    org = Organizations.where(:name => user.organization)
    role = ""
    CSV.parse(org.lead_ids) do |row|
      if user_id == row.to_s
        role = "lead"
      end
    end
    CSV.parse(org.admin_ids) do |row|
      if user_id == row.to_s
        role = "admin"
      end
    end
    return role
  end

  # get the user's Organization
  # @param [organization_id] organization.id
  # @return organization
  def self.get_organization_by_id(organization_id)
    organizations = Organizations.where(:id => organization_id)
    organization = organizations.first
    return organization
  end

end
