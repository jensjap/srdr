# == Schema Information
#
# Table name: design_detail_data_points
#
#  id                     :integer          not null, primary key
#  design_detail_field_id :integer
#  value                  :text
#  notes                  :text
#  study_id               :integer
#  extraction_form_id     :integer
#  created_at             :datetime
#  updated_at             :datetime
#  subquestion_value      :string(255)
#  row_field_id           :integer          default(0)
#  column_field_id        :integer          default(0)
#  arm_id                 :integer          default(0)
#  outcome_id             :integer          default(0)
#

class DesignDetailDataPoint < ActiveRecord::Base
  include GlobalModelMethod

  before_save :clean_string

	belongs_to :design_detail, foreign_key: "design_detail_field_id"
	belongs_to :study, :touch=>true
	scope :all_datapoints_for_study, lambda{|q_list, study_id, model_name| where("#{model_name}_field_id IN (?) AND study_id=?", q_list, study_id).
				select(["#{model_name}_field_id","value","notes","subquestion_value","row_field_id","column_field_id","arm_id","outcome_id"])}

	# get_result
	# get the result (data point) from the given question
	def self.get_result(question,study_id)
		id = question.id
		@result = DesignDetailDataPoint.where(:design_detail_field_id => id, :study_id=>study_id).all
		return @result
	end
	
	# has_subquestion
	# Determine whether or not the field used to select the data point was assigned a subquestion
	def has_subquestion
		has_sq = false
		field = DesignDetailField.where(:option_text=>self.value, :design_detail_id=>self.design_detail_field_id).first
		unless field.nil?
			if field.has_subquestion == true
				has_sq = true
			end
		end
	end
	
	# save_data
	# Save the values coming in from the design details table
	def self.save_data(params,study_id)
		dd = params[:design_detail]
		# convert escaped quotes to normal before saving
		dd = QuestionBuilder.unescape_quotes(dd)
		submitted_questions = []  # an array to keep record of the questions answered in this submission
		if params[:design_detail_sub].nil?
			dd_subquestions = nil
		else
			dd_subquestions = params[:design_detail_sub]
		end
		ef_id = params[:design_detail_data_point][:extraction_form_id]		
		success = "true"
		unless dd.empty? || dd.nil?
			dd.keys.each do |key|
				selection = dd[key]
				qid, rowid, colid = key.split("_")

				# capture the id of the question so that we know the user intended to save to this
				submitted_questions << qid   

				rowid = rowid.nil? ? 0 : rowid
				colid = colid.nil? ? 0 : colid
		
				# HANDLE THE CASE WHEN MULTIPLE VALUES ARE PASSED (CHECK BOXES)
				if selection.class == Array
					if dd_subquestions.nil?
						subq_values = []
					else
						subq_values = dd_subquestions.values
					end
					existing = DesignDetailDataPoint.find(:all, :conditions=>['design_detail_field_id=? AND study_id=? AND extraction_form_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,rowid,colid])
					
					existing.each do |entry|
						if selection.include?(entry.value) 
							if subq_values.include?(entry.subquestion_value)
								selection.delete(entry.value)
							else
								entry.destroy()
							end
						else
							entry.destroy()
						end
					end
					
					selection.each do |choice|
						
						dat = DesignDetailDataPoint.new
						dat.design_detail_field_id = qid
						dat.row_field_id = rowid
						dat.column_field_id = colid
						dat.value = choice
						dat.study_id = study_id
						dat.extraction_form_id = ef_id
						unless dd_subquestions.nil? 
							unless dd_subquestions[key.to_s].nil?
								tmpField = DesignDetailField.where(:design_detail_id=>qid, :option_text=>choice).select("id")
								tmpField = tmpField[0].id unless tmpField.empty?
								dat.subquestion_value = dd_subquestions[qid.to_s][tmpField.to_s] unless dd_subquestions[qid.to_s][tmpField.to_s].nil?
							end
						end

						if !dat.save
							success=false
						end
					end
					params.delete(key)
				# AND IF ONLY A SINGLE VALUE HAS BEEN PASSED IN...
				else
					puts "SAVING DESIGN DETAIL DATA AND THE KEY IS #{key}\n\n"
					dat = DesignDetailDataPoint.find(:first, :conditions=>['design_detail_field_id=? AND study_id=? AND extraction_form_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,rowid,colid])
					#dat = DesignDetailDataPoint.where(:design_detail_field_id=>key, :study_id=>study_id, :extraction_form_id => ef_id).first
					if dd[key].empty?
						dat.destroy unless dat.nil?
					else
						if(dat.nil?)
							dat = DesignDetailDataPoint.new
							puts "CREATED A NEW DATAPOINT. \n"
						else
							puts "FOUND EXISTING...#{dat.id}"
						end
						dat.design_detail_field_id = qid
						dat.row_field_id = rowid
						dat.column_field_id = colid
						dat.value = dd[key]
						dat.study_id = study_id
						dat.extraction_form_id = ef_id
						unless dd_subquestions.nil?
							unless dd_subquestions[key.to_s].nil?
								dat.subquestion_value = dd_subquestions[key.to_s]
							end
						end
						if !dat.save
							success = false
							puts "DID NOT SAVE PROPERLY."
						else
							puts "SAVED PROPERLY!"
						end
					end
				end
			end		
		else
			success = false
		end
		# find any pre-existing data points that were saved for questions other than those submitted this time, and remove them
		old_dps = DesignDetailDataPoint.find(:all, :conditions=>["study_id=? AND extraction_form_id=? AND design_detail_field_id NOT IN (?)",study_id, ef_id, submitted_questions])
		old_dps.each do |d|
			d.destroy
		end
		return success
	end
end
