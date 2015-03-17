# == Schema Information
#
# Table name: arm_detail_data_points
#
#  id                  :integer          not null, primary key
#  arm_detail_field_id :integer
#  value               :text
#  notes               :text
#  study_id            :integer
#  extraction_form_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  arm_id              :integer          default(0)
#  subquestion_value   :string(255)
#  row_field_id        :integer          default(0)
#  column_field_id     :integer          default(0)
#  outcome_id          :integer          default(0)
#

class ArmDetailDataPoint < ActiveRecord::Base
  include GlobalModelMethod

	before_save :clean_string

	belongs_to :arm_detail_field
	belongs_to :study, :touch=>true
	belongs_to :arm
	scope :all_datapoints_for_study, lambda{|q_list, study_id, model_name| where("#{model_name}_field_id IN (?) AND study_id=?", q_list, study_id).
				select(["#{model_name}_field_id","value","notes","subquestion_value","row_field_id","column_field_id","arm_id"])}
		
	# get_result
	# get the result (data point) based on a given question
	def self.get_result(question,study_id,arm_id)
		id = question.id
		@result = ArmDetailDataPoint.where(:arm_detail_field_id => id,:study_id=>study_id,:arm_id=>arm_id).all
		return @result
	end
	
	# has_subquestion
	# Determine whether or not the field used to select the data point was assigned a subquestion
	def has_subquestion
		has_sq = false
		field = ArmDetailField.where(:option_text=>self.value, :arm_detail_id=>self.arm_detail_field_id).first
		unless field.nil?
			if field.has_subquestion == true
				has_sq = true
			end
		end
	end
	
	# save_data
	# save the values coming in from the design details table
	# 
	# Note: The keys for arm_detail parameters hash are in the foramt:
	# aaa_bbb_ccc-ddd
	# aaa = the id of the question itself
	# bbb = the id of the answer row
	# ccc = the id of the answer column (optional - applies to matrices)
	# ddd = the id of the arm data is saved to 
	def self.save_data(params,study_id)
		begin
		puts "SAVING ARM DETAILS\n"
		# determine if the arm details in this extraction form are listed by arm
		# if they are, then capture data for each arm
		by_arm = EfSectionOption.is_section_by_category?(params[:arm_detail_data_point][:extraction_form_id],'arm_detail')
		if by_arm
			puts "IN THE BY_ARM SECTION"
			submitted_questions = []
			details = params[:arm_detail]
			# convert escaped quotes to normal before saving
			details = QuestionBuilder.unescape_quotes(details)

			detail_subquestions = nil

			unless params[:arm_detail_sub].nil?
				detail_subquestions = params[:arm_detail_sub]
				puts "SUBQUESTIONS ARE: #{detail_subquestions}"
			end
			ef_id = params[:arm_detail_data_point][:extraction_form_id]
			success = "true"
			unless details.empty? || details.nil?
				details.keys.each do |key|
					detail_id, arm_id = key.split("-")
					selection = details[key]
					qid, rowid, colid = detail_id.split("_")
					rowid = rowid.nil? ? 0 : rowid
					colid = colid.nil? ? 0 : colid
					
					# HANDLE THE CASE WHEN MULTIPLE VALUES ARE PASSED
					if selection.class == Array
						if detail_subquestions.nil?
							subq_values = []
						else 
							subq_values = detail_subquestions.values
							puts "SUBQ VALUES ARE: #{subq_values}\n\n"
						end
						#existing = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id=>qid, :study_id=>study_id, :extraction_form_id => ef_id, :arm_id=>arm_id)
						existing = ArmDetailDataPoint.find(:all, :conditions=>['arm_detail_field_id=? AND study_id=? AND extraction_form_id=? AND arm_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id, arm_id,rowid,colid])
						
						existing.each do |entry|
							entry.destroy()
						end
						submitted_questions << "#{qid}_#{arm_id}" unless selection.empty?
						selection.each do |choice|
							print "CHOICE: #{choice}\n"
							dat = ArmDetailDataPoint.new
							dat.arm_detail_field_id = qid
							dat.row_field_id = rowid
							dat.column_field_id = colid
							dat.arm_id = arm_id
							dat.value = choice
							dat.study_id = study_id
							dat.extraction_form_id = ef_id
							unless detail_subquestions.nil?
								unless detail_subquestions[key.to_s].nil?
									tmpField = ArmDetailField.where(:arm_detail_id=>qid, :option_text=>choice).select("id");
									tmpField = tmpField[0].id unless tmpField.empty?
									sq_val = detail_subquestions[key.to_s]
									puts "SQ VAL IS #{sq_val}\n\n"
									if sq_val.class == ActiveSupport::HashWithIndifferentAccess 
										sq_val.stringify_keys!
										val = sq_val[tmpField.to_s]
										dat.subquestion_value = val
									else
										dat.subquestion_value = sq_val
									end
								end
							end
							
							if !dat.save
								success=false
							end
						end
						params.delete(key)
					# IF ONLY A SINGLE VALUE IS PASSED IN...
					else
						#dat = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id=>	qid, :arm_id=>arm_id, :study_id=>study_id, :extraction_form_id => ef_id).first
						dat = ArmDetailDataPoint.find(:first, :conditions=>['arm_detail_field_id=? AND study_id=? AND extraction_form_id=? AND arm_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,arm_id,rowid,colid])
						if details[key].empty?
							dat.destroy unless dat.nil?
						else
							submitted_questions << "#{qid}_#{arm_id}"
							if(dat.nil?)
								dat = ArmDetailDataPoint.new
							end
							dat.arm_detail_field_id = qid
							dat.row_field_id = rowid
							dat.column_field_id = colid
							dat.arm_id = arm_id
							dat.value = details[key]
							dat.study_id = study_id
							dat.extraction_form_id = ef_id
							unless detail_subquestions.nil? 
								unless detail_subquestions[key].nil?
									dat.subquestion_value = detail_subquestions[key]
								end
							end
							if !dat.save
								success = false
							end
						end
					end
				end	
			end	
		# ELSE IF IT'S NOT BY ARM
		else
			details = params[:arm_detail]
			details = QuestionBuilder.unescape_quotes(details)

			submitted_questions = []
			detail_subquestions = nil
			unless params[:arm_detail_sub].nil?
				detail_subquestions = params[:arm_detail_sub]
			end
			
			ef_id = params[:arm_detail_data_point][:extraction_form_id]
			success = true

			unless details.empty? || details.nil?
				details.keys.each do |key|
					detail_id, category_id = key.split("-")
					selection = details[key]
	                category_id = 0 if category_id.nil?
					puts "SAVING arm_detail DATAPOINT\n\n------------\n\n THE KEY IS #{key} AND AFTER SPLITTING THE outcome OUT IT'S #{category_id}\n\n\n"
					qid, rowid, colid = detail_id.split("_")
					rowid = rowid.nil? ? 0 : rowid
					colid = colid.nil? ? 0 : colid
					
					# HANDLE THE CASE WHEN MULTIPLE VALUES ARE PASSED
					if selection.class == Array
						if detail_subquestions.nil?
							subq_values = []
						else 
							subq_values = detail_subquestions.values
						end
						#existing = ArmDetailDataPoint.where(:arm_detail_field_id=>qid, :study_id=>study_id, :extraction_form_id => ef_id, :arm_id=>arm_id)
						existing = ArmDetailDataPoint.find(:all, :conditions=>['arm_detail_field_id=? AND study_id=? AND extraction_form_id=? AND arm_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,category_id,rowid,colid])
						
						existing.each do |entry|
							entry.destroy()
						end
						submitted_questions << "#{qid}_#{category_id}" unless selection.empty?
						selection.each do |choice|
							unless choice.blank?
								print "CHOICE: #{choice}\n"
								dat = ArmDetailDataPoint.new
								dat.arm_detail_field_id = qid
								dat.row_field_id = rowid
								dat.column_field_id = colid
								dat.arm_id = category_id
								dat.value = choice
								dat.study_id = study_id
								dat.extraction_form_id = ef_id
								unless detail_subquestions.nil?
									unless detail_subquestions[key.to_s].nil?
										tmpField = ArmDetailField.where(:arm_detail_id=>qid, :option_text=>choice).select("id");
										tmpField = tmpField[0].id unless tmpField.empty?
										sq_val = detail_subquestions[key.to_s]
										if sq_val.class == ActiveSupport::HashWithIndifferentAccess 
											sq_val.stringify_keys!
											val = sq_val[tmpField.to_s]
											dat.subquestion_value = val
										else
											dat.subquestion_value = sq_val
										end
									end
								end
								
								if !dat.save
									success=false
								end
							end
						end
						params.delete(key)
					# IF ONLY A SINGLE VALUE IS PASSED IN...
					else
						
						#dat = ArmDetailDataPoint.where(:arm_detail_field_id=>	qid, :arm_id=>arm_id, :study_id=>study_id, :extraction_form_id => ef_id).first
						dat = ArmDetailDataPoint.find(:first, :conditions=>['arm_detail_field_id=? AND study_id=? AND extraction_form_id=? AND arm_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,category_id,rowid,colid])
						
						if details[key].empty?
							dat.destroy unless dat.nil?
						else
							submitted_questions << "#{qid}_#{category_id}"
							if(dat.nil?)
								dat = ArmDetailDataPoint.new
							end
							dat.arm_detail_field_id = qid
							dat.row_field_id = rowid
							dat.column_field_id = colid
							dat.arm_id = category_id
							dat.value = details[key]
							dat.study_id = study_id
							dat.extraction_form_id = ef_id
							unless detail_subquestions.nil? 
								unless detail_subquestions[key].nil?
									dat.subquestion_value = detail_subquestions[key]
								end
							end
							if !dat.save
								success = false
							end
						end
					end
				end	
			else
				success = false
			end
		end
		# find any pre-existing data points that were saved for questions other than those submitted this time, and remove them
		puts "THE SUBMITTED QUESTIONS ARRAY CONTAINS: #{submitted_questions.join(", ")}\n\n"
		all_dps = ArmDetailDataPoint.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id, ef_id])		
		submitted_questions.uniq!
		submitted_questions.each do |sq|
			q, a = sq.split("_")
			all_dps.delete_if{|x| x.arm_detail_field_id == q.to_i && x.arm_id == a.to_i}
		end
		puts "REMOVING #{all_dps.length} DATA POINTS"
		all_dps.each do |d|
			d.destroy
		end
		return success
		rescue Exception => e
			puts "ERROR: #{e.message}...\n#{e.backtrace}\n\n\n"
		end
	end
end
