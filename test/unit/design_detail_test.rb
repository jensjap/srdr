# == Schema Information
#
# Table name: design_details
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

require 'test_helper'

class DesignDetailTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test get_fields
    test "should return the names of the three fields for dd1" do
        assert_equal 3, @study1_dd1.get_fields.length
        assert_equal "RCT", @study1_dd1.get_fields.first.option_text
        assert_equal "DesignDetailField", @study1_dd1.get_fields.first.class.name
    end

    # test remove_fields
    test "should remove all fields for design detail 1" do
      assert_difference('DesignDetailField.count',-3) do
            @study1_dd1.remove_fields
      end
    end

    # test has_study_data
    test "should return true only if data points exist" do 
        assert DesignDetail.has_study_data(@study1_dd1.id)
        assert !DesignDetail.has_study_data(@study1_dd2.id)
    end
end
