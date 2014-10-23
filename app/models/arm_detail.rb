# == Schema Information
#
# Table name: arm_details
#
#  id                      :integer          not null, primary key
#  question                :text
#  extraction_form_id      :integer
#  field_type              :string(255)
#  field_note              :string(255)
#  question_number         :integer
#  study_id                :integer
#  created_at              :datetime
#  updated_at              :datetime
#  instruction             :text
#  is_matrix               :boolean          default(FALSE)
#  include_other_as_option :boolean
#

class ArmDetail < ActiveRecord::Base
    belongs_to :extraction_form, :touch=>true
    has_many :arm_detail_fields, :dependent=>:destroy
    #has_many :arm_detail_data_points, :through=>:arm_detail_fields
    validates :question, :presence => true
    scope :questions_for_ef, lambda{|efid| where("extraction_form_id=?",efid).
                select(["id","question","question_number","field_type","instruction","is_matrix","include_other_as_option"]).
                order("question_number ASC")}
    # get_fields
    # return arm_detail_fields for this design detail
    def get_fields
        return self.arm_detail_fields.order("row_number ASC, created_at ASC")
    end

    # remove_fields
    # remove arm_detail_fields for this arm_detail
    def remove_fields
        fields = self.arm_detail_fields
        fields.each do |field|
            field.destroy
        end
    end

    # return the subquestion for fields in the design detail. If there isn't one, return an
    # empty string
    def get_subquestion
        fields = self.arm_detail_fields
        subq = nil
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

    #has_study_data
    def self.has_study_data id
        return false;
    end

    #check whether a study has been created that uses this extraction_form_arm name
    #used for alerting users when editing
=begin
    def self.has_study_data(id)
        datapoints = ArmDetailDataPoint.where(:arm_detail_field_id => id).all
        if datapoints.nil? || (datapoints.length == 0)
            return "false"
        else
            return "true"
        end
    end
=end


end
