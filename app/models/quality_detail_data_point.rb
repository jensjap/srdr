# == Schema Information
#
# Table name: quality_detail_data_points
#
#  id                      :integer          not null, primary key
#  quality_detail_field_id :integer
#  value                   :text
#  notes                   :text
#  study_id                :integer
#  extraction_form_id      :integer
#  created_at              :datetime
#  updated_at              :datetime
#  subquestion_value       :string(255)
#  row_field_id            :integer          default(0)
#  column_field_id         :integer          default(0)
#  arm_id                  :integer          default(0)
#  outcome_id              :integer          default(0)
#

class QualityDetailDataPoint < ActiveRecord::Base
  include GlobalModelMethod

  before_save :clean_string

  belongs_to :quality_detail_field
  belongs_to :study, :touch=>true
  scope :all_datapoints_for_study, lambda{|q_list, study_id, model_name| where("#{model_name}_field_id IN (?) AND study_id=?", q_list, study_id).
        select(["#{model_name}_field_id","value","notes","subquestion_value","row_field_id","column_field_id","outcome_id"])}

  
  # get_result
  # get the result (data point) from the given question
  def self.get_result(question,study_id)
    id = question.id
    @result = QualityDetailDataPoint.where(:quality_detail_field_id => id, :study_id=>study_id).all
    return @result
  end
  
  # has_subquestion
  # Determine whether or not the field used to select the data point was assigned a subquestion
  def has_subquestion
    has_sq = false
    field = QualityDetailField.where(:option_text=>self.value, :quality_detail_id=>self.quality_detail_field_id).first
    unless field.nil?
      if field.has_subquestion == true
        has_sq = true
      end
    end
  end
  
  def self.save_data(params,study_id)
    # determine if the quality details in this extraction form are listed by outcome
    # if they are, then capture data for each outcome
    by_outcome = EfSectionOption.is_section_by_category?(params[:quality_detail_data_point][:extraction_form_id],'quality_detail')
    if by_outcome
      submitted_questions = []
      details = params[:quality_detail]
      # convert escaped quotes to normal before saving
      details = QuestionBuilder.unescape_quotes(details)

      detail_subquestions = nil

      unless params[:quality_detail_sub].nil?
        detail_subquestions = params[:quality_detail_sub]
      end
      ef_id = params[:quality_detail_data_point][:extraction_form_id]
      success = "true"
      unless details.empty? || details.nil?
        details.keys.each do |key|
          detail_id, outcome_id = key.split("-")
          selection = details[key]
          puts "SAVING OUTCOME DETAIL DATAPOINT\n\n------------\n\n THE KEY IS #{key} AND AFTER SPLITTING THE OUTCOME OUT IT'S #{detail_id}\n\n\n"
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
            #existing = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id=>qid, :study_id=>study_id, :extraction_form_id => ef_id, :arm_id=>arm_id)
            existing = QualityDetailDataPoint.find(:all, :conditions=>['quality_detail_field_id=? AND study_id=? AND extraction_form_id=? AND outcome_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id, outcome_id,rowid,colid])
            
            existing.each do |entry|
              entry.destroy()
            end
            submitted_questions << "#{qid}_#{outcome_id}" unless selection.empty?
            selection.each do |choice|
              print "CHOICE: #{choice}\n"
              dat = QualityDetailDataPoint.new
              dat.quality_detail_field_id = qid
              dat.row_field_id = rowid
              dat.column_field_id = colid
              dat.outcome_id = outcome_id
              dat.value = choice
              dat.study_id = study_id
              dat.extraction_form_id = ef_id
              unless detail_subquestions.nil?
                unless detail_subquestions[key.to_s].nil?
                  tmpField = QualityDetailField.where(:quality_detail_id=>qid, :option_text=>choice).select("id");
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
            params.delete(key)
          # IF ONLY A SINGLE VALUE IS PASSED IN...
          else
            #dat = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id=>  qid, :arm_id=>arm_id, :study_id=>study_id, :extraction_form_id => ef_id).first
            dat = QualityDetailDataPoint.find(:first, :conditions=>['quality_detail_field_id=? AND study_id=? AND extraction_form_id=? AND outcome_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,outcome_id,rowid,colid])
            if details[key].empty?
              dat.destroy unless dat.nil?
            else
              submitted_questions << "#{qid}_#{outcome_id}"
              if(dat.nil?)
                dat = QualityDetailDataPoint.new
              end
              dat.quality_detail_field_id = qid
              dat.row_field_id = rowid
              dat.column_field_id = colid
              dat.outcome_id = outcome_id
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
    # ELSE IF IT's NOT BY OUTCOME
    else


      details = params[:quality_detail]
      details = QuestionBuilder.unescape_quotes(details)

      submitted_questions = []
      detail_subquestions = nil
      unless params[:quality_detail_sub].nil?
        detail_subquestions = params[:quality_detail_sub]
      end
      
      ef_id = params[:quality_detail_data_point][:extraction_form_id]
      success = true

      unless details.empty? || details.nil?
        details.keys.each do |key|
          detail_id, category_id = key.split("-")
          selection = details[key]
                  category_id = 0 if category_id.nil?
          puts "SAVING quality_detail DATAPOINT\n\n------------\n\n THE KEY IS #{key} AND AFTER SPLITTING THE outcome OUT IT'S #{category_id}\n\n\n"
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
            existing = QualityDetailDataPoint.find(:all, :conditions=>['quality_detail_field_id=? AND study_id=? AND extraction_form_id=? AND outcome_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,category_id,rowid,colid])
            
            existing.each do |entry|
              entry.destroy()
            end
            submitted_questions << "#{qid}_#{category_id}" unless selection.empty?
            selection.each do |choice|
              unless choice.blank?
                print "CHOICE: #{choice}\n"
                dat = QualityDetailDataPoint.new
                dat.quality_detail_field_id = qid
                dat.row_field_id = rowid
                dat.column_field_id = colid
                dat.outcome_id = category_id
                dat.value = choice
                dat.study_id = study_id
                dat.extraction_form_id = ef_id
                unless detail_subquestions.nil?
                  unless detail_subquestions[key.to_s].nil?
                    tmpField = QualityDetailField.where(:quality_detail_id=>qid, :option_text=>choice).select("id");
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
            
            #dat = ArmDetailDataPoint.where(:arm_detail_field_id=>  qid, :arm_id=>arm_id, :study_id=>study_id, :extraction_form_id => ef_id).first
            dat = QualityDetailDataPoint.find(:first, :conditions=>['quality_detail_field_id=? AND study_id=? AND extraction_form_id=? AND outcome_id=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)',qid,study_id,ef_id,category_id,rowid,colid])
            
            if details[key].empty?
              dat.destroy unless dat.nil?
            else
              submitted_questions << "#{qid}_#{category_id}"
              if(dat.nil?)
                dat = QualityDetailDataPoint.new
              end
              dat.quality_detail_field_id = qid
              dat.row_field_id = rowid
              dat.column_field_id = colid
              dat.outcome_id = category_id
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
    all_dps = QualityDetailDataPoint.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id, ef_id])   
    submitted_questions.uniq!
    submitted_questions.each do |sq|
      q, a = sq.split("_")
      all_dps.delete_if{|x| x.quality_detail_field_id == q.to_i && x.outcome_id == a.to_i}
    end
    puts "REMOVING #{all_dps.length} DATA POINTS"
    all_dps.each do |d|
      d.destroy
    end
    return success
  end
  
end
