# == Schema Information
#
# Table name: baseline_characteristics
#
#  id                      :integer          not null, primary key
#  question                :text
#  field_type              :string(255)
#  extraction_form_id      :integer
#  field_notes             :string(255)
#  question_number         :integer
#  study_id                :integer
#  created_at              :datetime
#  updated_at              :datetime
#  instruction             :text
#  is_matrix               :boolean          default(FALSE)
#  include_other_as_option :boolean
#

class BaselineCharacteristic < ActiveRecord::Base
    include GlobalModelMethod

    before_save :clean_string

    belongs_to :extraction_form, :touch=>true
    has_many :baseline_characteristic_data_points, :through=>:baseline_characteristic_fields
    has_many :baseline_characteristic_fields, :dependent=>:destroy
    validates :question, :presence => true
    scope :questions_for_ef, lambda{|efid| where("extraction_form_id=?",efid).
                select(["id","question","question_number","field_type","instruction","is_matrix","include_other_as_option"]).
                order("question_number ASC")}
    # get_fields
    # return baseline characteristic fields based on the selected baseline characteristic
    def get_fields
        return self.baseline_characteristic_fields.order("row_number ASC, created_at ASC")
    end

    # return the subquestion for fields in the baseline_characteristic. 
    # If there isn't one, return an empty string
    def get_subquestion
        fields = self.baseline_characteristic_fields
        subq = ""
        unless fields.empty?
            fields.each do |field|
              if field.has_subquestion == true
                subq = field.subquestion
                break;
              end
            end
        end
        return subq
    end
    # remove_fields
    # remove baseline characteristic fields based on the selected baseline characteristic
    def remove_fields
        fields = self.baseline_characteristic_fields
        fields.each do |field|
            field.destroy
        end
    end

    #has_study_data
    #check whether a study has been created that uses this extraction_form_arm name
    #used for alerting users when editing
    def self.has_study_data(id)
        datapoints = BaselineCharacteristicDataPoint.where(:baseline_characteristic_field_id => id).all
        if datapoints.nil? || (datapoints.length == 0)
            return false
        else
            return true
        end
    end
end
