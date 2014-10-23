# == Schema Information
#
# Table name: extraction_form_key_questions
#
#  id                 :integer          not null, primary key
#  extraction_form_id :integer
#  key_question_id    :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class ExtractionFormKeyQuestion < ActiveRecord::Base
	belongs_to :extraction_form, :touch=>true
end
