# == Schema Information
#
# Table name: study_extraction_forms
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# @deprecated
# can be deleted?
# To link studies, key questions and extraction forms, use study_key_questions.
#
# This class contains the fields study_id and extraction_form_id. An entry in the study_extraction_form table indicates that
# the study uses that particular extraction form for storing data.
class StudyExtractionForm < ActiveRecord::Base
    belongs_to :study, touch: true
    belongs_to :extraction_form, touch: true
end
