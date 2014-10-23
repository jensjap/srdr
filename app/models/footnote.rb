# == Schema Information
#
# Table name: footnotes
#
#  id          :integer          not null, primary key
#  note_number :integer
#  study_id    :integer
#  page_name   :string(255)
#  data_type   :string(255)
#  note_text   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Footnote < ActiveRecord::Base
	belongs_to :study, :touch=>true
	# remove footnotes for the given study id
	def self.remove_entries(sid, page_name)
		footnotes = Footnote.where(:study_id=>sid, :page_name=>page_name)
		unless footnotes.empty?
			footnotes.each do |fnote|
				fnote.destroy
			end
		end
	end
	
	# return the number for a given footnote.
	def self.get_note_number(footnote_id)
		note = Footnote.find(footnote_id)
		return note.note_number
	end
	
	def self.get_cont_field_ids(study_id, extraction_form_continuous_columns, continuous_outcomes, continuous_timepoints, extraction_form_id)
		@study = Study.find(study_id)	
		@study_arms = Arm.where(:study_id => @study.id, :extraction_form_id => extraction_form_id).all	
		@study_arm_ids = @study_arms.collect{|arm| arm.id}	
	
		@cont_outcome_ids = continuous_outcomes.collect{|contOut| contOut.id}
		@cont_cols = extraction_form_continuous_columns.collect{|contCols| contCols.id}
		
		continuous_fields = OutcomeResult.get_list_of_field_ids(@cont_outcome_ids, @study_arm_ids, continuous_timepoints, @cont_cols)	
		@cont_field_ids = continuous_fields.to_json
		@cont_field_ids.gsub!(/[\"\[\]]/,"")
		return @cont_field_ids
	end
	
	def self.get_cat_field_ids(study_id, extraction_form_categorical_columns, categorical_outcomes, categorical_timepoints, extraction_form_id)
		@study = Study.find(study_id)	
		@study_arms = Arm.where(:study_id => @study.id, :extraction_form_id => extraction_form_id).all	
		@study_arm_ids = @study_arms.collect{|arm| arm.id}	
	
		@cat_outcome_ids = categorical_outcomes.collect{|catOut| catOut.id}	
		@cat_cols = extraction_form_categorical_columns.collect{|catCols| catCols.id}
		
		categorical_fields = OutcomeResult.get_list_of_field_ids(@cat_outcome_ids, @study_arm_ids, categorical_timepoints, @cat_cols)	
		@cat_field_ids = categorical_fields.to_json
		@cat_field_ids.gsub!(/[\"\[\]]/,"")
		return @cat_field_ids
	end
	
	
	end
