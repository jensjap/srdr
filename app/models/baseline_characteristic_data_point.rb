# == Schema Information
#
# Table name: baseline_characteristic_data_points
#
#  id                               :integer          not null, primary key
#  baseline_characteristic_field_id :integer
#  value                            :text
#  notes                            :text
#  study_id                         :integer
#  extraction_form_id               :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  arm_id                           :integer          default(0)
#  subquestion_value                :string(255)
#  row_field_id                     :integer          default(0)
#  column_field_id                  :integer          default(0)
#  outcome_id                       :integer          default(0)
#

class BaselineCharacteristicDataPoint < ActiveRecord::Base
    include GlobalModelMethod

    before_save :clean_string

    belongs_to :baseline_characteristic, foreign_key: "baseline_characteristic_field_id"
    belongs_to :study, :touch=>true
    belongs_to :arm
    scope :all_datapoints_for_study, lambda{|q_list, study_id, model_name| where("#{model_name}_field_id IN (?) AND study_id=?", q_list, study_id).
                select(["#{model_name}_field_id","value","notes","subquestion_value","row_field_id","column_field_id","arm_id","outcome_id","diagnostic_test_id"])}

    # get_result
    # get the result (data point) based on a given question
    def self.get_result(question,study_id,arm_id)
        id = question.id
        @result = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id => id,:study_id=>study_id,:arm_id=>arm_id).all
        return @result
    end

    # has_subquestion
    # Determine whether or not the field used to select the data point was assigned a subquestion
    def has_subquestion
        has_sq = false
        field = BaselineCharacteristicField.where(:option_text=>self.value, :baseline_characteristic_id=>self.baseline_characteristic_field_id).first
        unless field.nil?
            if field.has_subquestion == true
                has_sq = true
            end
        end
    end

    # save_data
    # save the values coming in from the design details table
    def self.save_data(params,study_id)
        submitted_questions = []
        bc = params[:baseline_characteristic]
        # convert escaped quotes to normal before saving
        bc = QuestionBuilder.unescape_quotes(bc)

        if params[:baseline_characteristic_sub].nil?
            bc_subquestions = nil
        else
            bc_subquestions = params[:baseline_characteristic_sub]
        end
        ef_id = params[:baseline_characteristic_data_point][:extraction_form_id]
        is_diagnostic = params[:baseline_characteristic_data_point][:is_diagnostic]
        success = "true"
        category_id_field = is_diagnostic == "true" ? "diagnostic_test_id" : "arm_id"
        puts "---------------\nCategory field id is #{category_id_field}\n"
        unless bc.empty? || bc.nil?
            bc.keys.each do |key|
                bc_id, category_id = key.split("-")
                puts "Category ID is #{category_id}\n"
                selection = bc[key]
                puts "SAVING BC DATAPOINT\n\n------------\n\n THE KEY IS #{key} AND AFTER SPLITTING THE ARM OUT IT'S #{bc_id}\n\n\n"
                qid, rowid, colid = bc_id.split("_")
                rowid = rowid.nil? ? 0 : rowid
                colid = colid.nil? ? 0 : colid
                # HANDLE THE CASE WHEN MULTIPLE VALUES ARE PASSED
                if selection.class == Array
                    if bc_subquestions.nil?
                        subq_values = []
                    else 
                        subq_values = bc_subquestions.values
                    end
                    existing = BaselineCharacteristicDataPoint.find(:all, :conditions=>["baseline_characteristic_field_id=? AND study_id=? AND extraction_form_id=? AND #{category_id_field}=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)",qid,study_id,ef_id, category_id,rowid,colid])

                    existing.each do |entry|
                        entry.destroy()
                    end
                    submitted_questions << "#{qid}_#{category_id}" unless selection.empty?
                    selection.each do |choice|
                        print "CHOICE: #{choice}\n"
                        dat = BaselineCharacteristicDataPoint.new
                        dat.baseline_characteristic_field_id = qid
                        dat.row_field_id = rowid
                        dat.column_field_id = colid
                        dat[category_id_field] = category_id
                        dat.value = choice
                        dat.study_id = study_id
                        dat.extraction_form_id = ef_id
                        unless bc_subquestions.nil?
                            unless bc_subquestions[key.to_s].nil?
                                tmpField = BaselineCharacteristicField.where(:baseline_characteristic_id=>qid, :option_text=>choice).select("id");
                                tmpField = tmpField[0].id unless tmpField.empty?
                                sq_val = bc_subquestions[key.to_s]
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
                    # NOTE 
                    # category_id_field is either arm_id or diagnostic_test_id depending on whether or not the extraction form is a diagnostic test form
                    dat = BaselineCharacteristicDataPoint.find(:first, :conditions=>["baseline_characteristic_field_id=? AND study_id=? AND extraction_form_id=? AND #{category_id_field}=? AND (row_field_id=? OR row_field_id IS NULL) AND (column_field_id=? OR column_field_id IS NULL)",qid,study_id,ef_id,category_id,rowid,colid])
                    if bc[key].empty?
                        dat.destroy unless dat.nil?
                    else
                        submitted_questions << "#{qid}_#{category_id}"
                        if(dat.nil?)
                            dat = BaselineCharacteristicDataPoint.new
                        end
                        dat.baseline_characteristic_field_id = qid
                        dat.row_field_id = rowid
                        dat.column_field_id = colid
                        dat[category_id_field] = category_id 
                        dat.value = bc[key]
                        dat.study_id = study_id
                        dat.extraction_form_id = ef_id
                        unless bc_subquestions.nil? 
                            unless bc_subquestions[key].nil?
                                dat.subquestion_value = bc_subquestions[key]
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
        # find any pre-existing data points that were saved for questions other than those submitted this time, and remove them
        all_dps = BaselineCharacteristicDataPoint.find(:all, :conditions=>["study_id=? AND extraction_form_id=?",study_id, ef_id])
        
        puts "category id field is #{category_id_field}\n\n"
        submitted_questions.each do |sq|
            q, a = sq.split("_")
            puts "Q is #{q} and A is #{a}\n"
            all_dps.delete_if{|x| x.baseline_characteristic_field_id == q.to_i && x[category_id_field] == a.to_i}
        end
        
        all_dps.each do |d|
            d.destroy
        end
        return success
    end
end
