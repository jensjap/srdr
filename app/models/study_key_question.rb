# == Schema Information
#
# Table name: study_key_questions
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  key_question_id    :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# A key question is linked to a study via the "study_key_questions" table which contains the fields study_id, key_question_id, 
# and extraction_form_id. This table links key questions to studies via extraction form (A study has a non-unique extraction_form_id).
class StudyKeyQuestion < ActiveRecord::Base
	belongs_to :study, :touch=>true
	belongs_to :key_question
end
