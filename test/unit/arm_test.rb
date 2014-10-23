# == Schema Information
#
# Table name: arms
#
#  id                    :integer          not null, primary key
#  study_id              :integer
#  title                 :string(255)
#  description           :text
#  display_number        :integer
#  extraction_form_id    :integer
#  created_at            :datetime
#  updated_at            :datetime
#  is_suggested_by_admin :boolean          default(FALSE)
#  note                  :string(255)
#  efarm_id              :integer
#  default_num_enrolled  :integer
#  is_intention_to_treat :boolean          default(TRUE)
#

require 'test_helper'

class ArmTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test creating a new arm
    test "should not allow to create an arm without a title" do
        with_title = Arm.new(:study_id=>1, :title=>"Title", :description=>"desc", :extraction_form_id=>1)
        without_title = Arm.new(:study_id=>1, :description=>"desc", :extraction_form_id=>1)
        assert with_title.save
        assert !without_title.save, "Saved without a title"
    end

    # test get display number
    test "should return the display number, or 1 if there are no previous entries" do
        assert_equal 3, @study1_arm1.get_display_number(1,1) # already has two, should return 3
        assert_equal 2, @study1_arm3.get_display_number(1,2) # already has one, should return 2
        assert_equal 1, @study1_arm2.get_display_number(1,3) # no entries for that ef exist, should return 1
    end

    # test shift display numbers
    test "should decrease the second display number to 1" do
        @study1_arm1.shift_display_numbers(@study1_arm1.study_id, @study1_arm1.extraction_form_id)
        arm2 = Arm.find(@study1_arm2.id)
        assert_equal 1, arm2.display_number
    end

    # test move_up_this
    test "should move display number for arm with id up one" do
        Arm.move_up_this(@study1_arm2.id, 1, 1)
        arm2 = Arm.find(@study1_arm2.id)
        assert_equal 1, arm2.display_number
    end

    # test decrease_other
    test "should increment the dispay numbers for both arm1 from 1 to 2" do
        # params are display_num, studyid, efid
        Arm.decrease_other(1,1,1)
        arm1 = Arm.find(@study1_arm1.id)
        arm2 = Arm.find(@study1_arm2.id)
        assert_equal 2, arm1.display_number
        assert_equal 2, arm2.display_number
    end
end
