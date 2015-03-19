# == Schema Information
#
# Table name: adverse_event_columns
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  description        :string(255)
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# This model handles adverse event columns. Adverse event columns are created in the extraction form adverse event section. 
# They cannot be modified by the data extractor.
# The adverse event column is linked to the extraction_form_id, and contains name and description.
class AdverseEventColumn < ActiveRecord::Base
    include GlobalModelMethod

    before_save :clean_string

    belongs_to :extraction_form, :touch=>true
    validates :name, :presence => true

    # check whether a study has been created that uses this extraction_form_arm name.
    # used for alerting users when editing
    # @param [string] id the adverse event column id
    # @return [boolean] whether the adverse event column has data associtated with it
    def self.has_study_data(id)
        @datapoints = AdverseEventResult.where(:column_id => id).all
        if @datapoints.nil? || (@datapoints.length == 0)
            return false
        else
            return true
        end
    end

end
