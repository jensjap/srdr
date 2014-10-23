# == Schema Information
#
# Table name: secondary_publication_numbers
#
#  id                       :integer          not null, primary key
#  secondary_publication_id :integer
#  number                   :string(255)
#  number_type              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

# This class handles secondary publication numbers for a secondary publication. 
# A secondary publication can have unlimited secondary publication numbers. 
class SecondaryPublicationNumber < ActiveRecord::Base
	belongs_to :secondary_publication
	attr_accessible :secondary_publication_id, :number, :number_type
	
end
