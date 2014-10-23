# == Schema Information
#
# Table name: outcomes
#
#  id                 :integer          not null, primary key
#  study_id           :integer
#  title              :string(255)
#  is_primary         :boolean
#  units              :string(255)
#  description        :text
#  notes              :text
#  outcome_type       :string(255)
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test that outcome cannot be created without title
    test "should not create without a title" do
       OutcomeTimepoint.create(:outcome_id=>1,:number=>1, :time_unit=>"month")
       OutcomeTimepoint.create(:outcome_id=>1, :number=>2, :time_unit=>"month")
       should_work = Outcome.new(@study1_outcome1.attributes)
       shouldnt_work = Outcome.new(@oc_no_title.attributes)
       print "\n\nOC NO TITLE: #{@oc_no_title.attributes}\n\n"
       assert should_work.save
       assert !shouldnt_work.save
    end

    # test outcome_has_measures
    test "should report true if measures exist and false otherwise" do
        assert Outcome.outcome_has_measures(@study1_outcome1)
        assert !Outcome.outcome_has_measures(@study1_outcome3)
    end

    # test at_least_one_has_data
    # if at least one of the outcomes in a list has measures then its true
    test "is true if one outcome has measures defined" do
      assert Outcome.at_least_one_has_data([@study1_outcome1, @study1_outcome2])
      assert !Outcome.at_least_one_has_data([@study1_outcome3])
  end

    # test get_timepoints
    test "should return a readable list of timepoints separated by commas" do
        assert_equal "1 month, 3 month, 5 month", Outcome.get_timepoints(@study1_outcome1.id)
        assert_equal "1 week, 2 week", Outcome.get_timepoints(@study1_outcome2.id)
        assert_equal "", Outcome.get_timepoints(@study1_outcome3.id)
    end

    # test get_timepoints_array
    # was designed to put a baseline timepoint at the front of the list, so the last element becomes the first
    test "should return an array of timepoint objects" do
        tps = Outcome.get_timepoints_array(@study1_outcome1)
        assert_equal 3, tps.length
        assert_equal "OutcomeTimepoint",tps.first.class.name
        assert_equal "5 month", tps.first.number.to_s + " " + tps.first.time_unit
    end

    # test get_timepoints_for_outcomes_array
    test "should return an array of timepoint object arrays" do
        tps = Outcome.get_timepoints_for_outcomes_array([@study1_outcome1, @study1_outcome2])
        assert_equal 2, tps.length        # returns an array for each of the two outcomes
        assert_equal 3, tps.first.length  # 3 timepoints for the first outcome
        assert_equal 2, tps[1].length     # 2 timepoints in the second outcome
        assert_equal "OutcomeTimepoint",tps.first.first.class.name
    end

    # test get_title
    test "should return Title of outcome 1" do
        assert_equal "Title of outcome 1", Outcome.get_title(@study1_outcome1.id)
    end

    # test get_array_of_titles
    test "should return an array of all titles for outcomes specified" do
        assert_equal 3, Outcome.get_array_of_titles([1,2,3]).length
        assert_equal ["Title of outcome 1","Title of outcome 2","Title of outcome 3"], Outcome.get_array_of_titles([1,2,3])
    end
end
