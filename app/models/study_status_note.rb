# == Schema Information
#
# Table name: study_status_notes
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  user_id            :integer
#  note               :text
#  created_at         :datetime
#  updated_at         :datetime
#

class StudyStatusNote < ActiveRecord::Base
	belongs_to :study, :touch=>true
end
