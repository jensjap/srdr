# == Schema Information
#
# Table name: key_questions
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  question_number :integer
#  question        :text
#  created_at      :datetime
#  updated_at      :datetime
#

require 'test_helper'

class KeyQuestionTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test question creation
    test "should create a new question" do
        q = KeyQuestion.new(:question=>"How are you?", :project_id=>2, :question_number=>2)
        assert q.save
    end

    # check that question text is required for creation
    test "should not work without a question" do
        q = KeyQuestion.new(:project_id=>2, :question_number=>2)
        assert !q.save, 'Saved the kq without a question'
    end

    # test get_question_number
    # there are two kqs defined for project 3
    test "should return the next question number of 3" do
        assert_equal 3, @proj1_kq1.get_question_number(@proj1_kq1.project_id)
        kq = KeyQuestion.create(:question=>"Blah",:project_id=>1,:question_number=>3)
        assert_equal 4, @proj1_kq1.get_question_number(@proj1_kq1.project_id)
    end

    # test shift_question_numbers
    # (used when a kq is deleted, should decrement all question numbers above the one deleted)
    test "should return the highest key question number of 1" do
        @proj1_kq1.shift_question_numbers(@proj1_kq1.project_id)
        nums = KeyQuestion.where(:project_id=>@proj1_kq1.project_id).collect{|x| x.question_number}
        assert_equal 1, nums.max
    end

    # test remove_from_junction
    # remove the second project from the junction. Make sure it worked by checking that none exist
    test "should empty key question 3 (proj2_kq1) from the study_key_question table" do
        @proj2_kq1.remove_from_junction
        assert StudyKeyQuestion.where(:key_question_id=>@proj2_kq1.id).empty?
    end

    # test format_for_display
    test "should format a list of question numbers for display" do
        questions = KeyQuestion.where(:project_id=>1)
        assert_equal "1 and 2", KeyQuestion.format_for_display(questions)
    end

    # test move_up_this (and decrease_other)
    test "should put the second kq into first position" do
        tmp = KeyQuestion.create!(:project_id=>1, :question=>'originally the last question', :question_number=>3)
        KeyQuestion.move_up_this(tmp.id, 1)
        one = KeyQuestion.where(:project_id=>1, :question_number=>1)
        two = KeyQuestion.where(:project_id=>1, :question_number=>2)
        three = KeyQuestion.where(:project_id=>1, :question_number=>3)
        # one should still be 'Why is the sky blue?'
        assert_equal "Why is the sky blue?", one.first.question
        # two should now be 'originally the last question'
        assert_equal "originally the last question", two.first.question
        # three should now be 'Where do babies come from'
        assert_equal "Where do babies come from?", three.first.question
    end

    # test get_extraction_form_id
    test "should return the extraction form id of 2 for the second key question" do
        assert_equal 2, KeyQuestion.get_extraction_form_id(@proj1_kq2.id)
    end

    # test has_extraction_form_assigned
    test "the first two questions should return true, the third should return false" do
        assert_equal Hash[1=>true,2=>true,3=>false], KeyQuestion.has_extraction_form_assigned(KeyQuestion.find(:all))
    end

    # test has_extraction_form
    test "should test whether or not extraction forms are assigned to particular kq" do
        # should return true
        assert_equal "true", KeyQuestion.has_extraction_form(1)

        # should return false
        assert_equal "false", KeyQuestion.has_extraction_form(3)
    end
end
