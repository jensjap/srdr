# == Schema Information
#
# Table name: primary_publications
#
#  id          :integer          not null, primary key
#  study_id    :integer
#  title       :text
#  author      :string(255)
#  country     :string(255)
#  year        :string(255)
#  pmid        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  journal     :string(255)
#  volume      :string(255)
#  issue       :string(255)
#  trial_title :string(255)
#

# This class handles primary publications for a study. A study has one primary publication, and a primary publication can have
# many primary publication numbers. The study title is derived from the title saved in the primary publication.
class PrimaryPublication < ActiveRecord::Base
	belongs_to :study, :touch=>true
	has_many :primary_publication_numbers, :dependent => :destroy
	accepts_nested_attributes_for :primary_publication_numbers, :allow_destroy => true	
end
