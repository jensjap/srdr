# == Schema Information
#
# Table name: extraction_forms
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  creator_id                  :integer
#  notes                       :text
#  adverse_event_display_arms  :boolean          default(TRUE)
#  adverse_event_display_total :boolean          default(TRUE)
#  created_at                  :datetime
#  updated_at                  :datetime
#  project_id                  :integer
#  is_ready                    :boolean
#  bank_id                     :integer
#  is_diagnostic               :boolean          default(FALSE)
#

require 'test_helper'

class ExtractionFormTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test can_be_removed
    test 'should disallow removal if studies use the form' do
      assert !@proj1_ef1.can_be_removed?, "Removed an EF that had a study associated with it"
      assert @standalone_ef.can_be_removed?, "Could not remove an empty EF"
    end

    # test is_title_unique_for_user
    test "shouldn't allow titles that already exist" do
        assert @proj1_ef1.is_title_unique_for_user("Form A",@project_lead, false), "Couldn't assign when it should have"
        assert @proj1_ef1.is_title_unique_for_user("Form A",@project_lead, true), "Couldn't update when it should have"
        assert !@proj1_ef1.is_title_unique_for_user("extraction form for key question 2",@project_lead, false), "Could assign when it shouldn't have"
        assert @proj1_ef1.is_title_unique_for_user("extraction form for key question 1",@project_lead, true), "Couldn't update when it should have"
        assert !@proj1_ef1.is_title_unique_for_user("extraction form for key question 2",@project_lead, true), "Could update when it should have"
    end

    # test get_assigned_key_questions
    test "ef2 should be assigned to kq2" do
        assert_equal [2], ExtractionForm.get_assigned_key_questions(@proj1_ef2.id)
    end

    # test get_assigned_question_numbers
    test "should provide assigned question numbers" do
        assert_equal [2], ExtractionForm.get_assigned_question_numbers(@proj1_ef2.id)
        assert_equal [1], ExtractionForm.get_assigned_question_numbers(@proj1_ef1.id)
    end

    # test get_available_questions
    test "should only provide key questions in the project that have not been assigned" do
      # the id of the third question for the project should be 4
      assert_equal [[3], {}], ExtractionForm.get_available_questions(2, @proj1_ef2.id)
      assert_equal [[],Hash[1=>"extraction form for key question 1", 2=>"extraction form for key question 2"]], ExtractionForm.get_available_questions(1,@standalone_ef)
  end

  # test out the create_included_sections function
  test "should create entries in the extraction_form_sections table" do
    assert_difference("ExtractionFormSection.count",10) do
        ExtractionForm.create_included_section_fields(@proj1_ef1)
    end
  end

  # test get_camel_caps
    test "should produce camel capped model name" do
        assert_equal "DesignDetail", ExtractionForm.get_camel_caps("design_detail")
    end

    # test no_sections_are_included
    test "should return true if no sections included" do
        assert ExtractionForm.no_sections_are_included(@proj1_ef1.id)
        ExtractionForm.create_included_section_fields(@proj1_ef1)
        assert !ExtractionForm.no_sections_are_included(@proj1_ef1.id)
    end

    # test get_kqs_covered
    test "should provide questions associated with the ef" do
        assert_equal "1", ExtractionForm.get_kqs_covered(1)
    end

    # test remove_extracted_data
    test "should remove all data for study 100 and ef 100" do
        # make sure all data is in place 
        assert_equal 1, Arm.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 2, Outcome.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 1, BaselineCharacteristicDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 2, DesignDetailDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 1, Comparison.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 2, ComparisonMeasure.where(:comparison_id=>1).length
        assert_equal 2, ComparisonDataPoint.where(:comparison_measure_id=>[1,2]).length
        assert_equal 1, OutcomeMeasure.where(:outcome_data_entry_id=>2).length
        assert_equal 2, OutcomeDataPoint.where(:arm_id=>[5,6]).length
        assert_equal 3, QualityDimensionDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 3, QualityRatingDataPoint.where(:study_id=>100, :extraction_form_id=>100).length

        # run the deletion method for sid=100 and efid=100
        ExtractionForm.remove_extracted_data(100,100)

        # make sure all data is gone
        assert_equal 0, Arm.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, Outcome.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, BaselineCharacteristicDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, DesignDetailDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, Comparison.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, ComparisonMeasure.where(:comparison_id=>1).length
        assert_equal 0, ComparisonDataPoint.where(:comparison_measure_id=>[1,2]).length
        assert_equal 0, OutcomeMeasure.where(:outcome_data_entry_id=>5).length
        assert_equal 0, OutcomeDataPoint.where(:arm_id=>[5,6]).length
        assert_equal 0, QualityDimensionDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
        assert_equal 0, QualityRatingDataPoint.where(:study_id=>100, :extraction_form_id=>100).length
    end
end
