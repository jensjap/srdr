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

  class Organization < ActiveRecord::Base

  end

