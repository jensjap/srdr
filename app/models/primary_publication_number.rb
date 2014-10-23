# == Schema Information
#
# Table name: primary_publication_numbers
#
#  id                     :integer          not null, primary key
#  primary_publication_id :integer
#  number                 :string(255)
#  number_type            :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

# This class handles primary publication numbers for a primary publication. 
# A primary publication can have unlimited primary publication numbers. 
class PrimaryPublicationNumber < ActiveRecord::Base
	belongs_to :primary_publication, :touch=>true
	attr_accessible :primary_publication_id, :number, :number_type
end
