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

require 'test_helper'

class BaselineCharacteristicTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test get_fields
    test "should return the names of the three fields for bc1" do
        assert_equal 3, @study1_bc1.get_fields.length
        assert_equal "RCT", @study1_bc1.get_fields.first.option_text
        assert_equal "BaselineCharacteristicField", @study1_bc1.get_fields.first.class.name
    end

    # test remove_fields
    test "should remove all fields for design detail 1" do
      assert_difference('BaselineCharacteristicField.count',-3) do
            @study1_bc1.remove_fields
      end
    end

    # test has_study_data
    test "should return true only if data points exist" do
        assert BaselineCharacteristic.has_study_data(@study1_bc1.id)
        assert !BaselineCharacteristic.has_study_data(@study1_bc2.id)
    end
end
