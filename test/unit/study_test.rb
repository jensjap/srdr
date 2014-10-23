# == Schema Information
#
# Table name: studies
#
#  id                 :integer          not null, primary key
#  project_id         :integer
#  study_type         :string(255)
#  creator_id         :integer
#  extraction_form_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class StudyTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test that studies can be created
    test "study should be created successfully" do
        stud = Study.new(@proj1_study1.attributes)
        assert stud.save
    end

    # test get_extraction_forms
    test "should return an array of two extraction forms" do
        assert_equal "ExtractionForm", @proj1_study1.get_extraction_forms[0].class.name, "Not a collection of extraction forms."
        assert_equal 2, @proj1_study1.get_extraction_forms.length, "There aren't 2 associated forms."
    end

    # test is_value_in_array
    test "is is_value_in_array working properly" do
        assert Study.is_value_in_array("Chris",["Chris","Seth","Ryan","Joe"]), "It should be there."
        assert !Study.is_value_in_array("Tom",["Chris","Seth","Ryan","Joe"]),"It's not in there."
    end

    # test get_arms
    test "study should have two arms" do
        assert_equal 3, Study.get_arms(@proj1_study1.id).length
        assert_equal "Arm", Study.get_arms(@proj1_study1.id)[0].class.name, "Did not find an arm"
    end

    # test get_outcomes
    test "study should have two outcomes" do
        assert_equal 4, Study.get_outcomes(@proj1_study1.id).length
        assert_equal "Outcome", Study.get_outcomes(@proj1_study1.id)[0].class.name, "Did not find outcome"
    end

    # test get_question_choices
    test "should return a list of the three key questions available" do
        assert_equal 2, @proj1_study1.get_question_choices(@proj1_study1.project_id).length
    end

    # test get_questions_addressed
    test "should list questions addressed as [1, 2]" do
        #tmp = @proj1_study1.get_questions_addressed(1)
        #print "\n\n\nKQs: #{tmp.to_sentence}\n\n\n"
        assert_equal [[1,1,"Why is the sky blue?"]], @proj1_study1.get_questions_addressed(1)
    end

    # test get_addressed_ids
    test "should return key question id for ef 2" do
        assert_equal [2], @proj1_study1.get_addressed_ids(2), "Returned the incorrect question ID"
    end

    # test remove_from_junction
    test "should remove study 2 from the study_key_questions junction" do
        assert_difference('StudyKeyQuestion.count', -1) do
            @proj1_study2.remove_from_junction
        end
    end

    # test remove_from_key_questionjunction
    # THIS IS A DUPLICATE FUNCTION
    test "should remove study 2 from the study_key_questions junction again" do
        assert_difference('StudyKeyQuestion.count', -1) do
            @proj1_study2.remove_from_key_question_junction
        end
    end

    # test get_primary_publication
    test "should return the primary publication" do
        x = @proj1_study1.get_primary_publication
        assert x.class.name == "PrimaryPublication"
        assert_equal x.title, "Study 1 title", 'Found an incorrect record.'
    end

    # test get_secondary_publications
    # note that the extraction form parameter input is unnecessary but hasn't been removed from
    # the code base yet.
    test "should return the secondary publications for study 1" do
        x = @proj1_study1.get_secondary_publications(0) #the 0 parameters is meaningless
        assert x[0].class.name == "SecondaryPublication"
        assert_equal 4, x.length
    end

    # test get_primary_pub_info
    test "should return the primary publication object for study 1" do
        x = Study.get_primary_pub_info(@proj1_study1.id)
        assert x.class.name == "PrimaryPublication"
        assert_equal x.title, "Study 1 title", 'Found an incorrect record.'

        # test the case where it can't find a primary publication for the study
        # should return an empty publication with fields that can be filled into the form
        y = Study.get_primary_pub_info(1000)
        assert_equal "Not Entered Yet", y.title
    end

    # test get_key_question_output
    test "should return the key question numbers in an array for study 1" do
        assert_equal ["1","2"], Study.get_key_question_output(@proj1_study1.id)
    end

    # test remove_from_extraction_form_junction
    test "should result in two less entry in study_extraction_forms" do
        assert_difference('StudyExtractionForm.count',-2) do
            @proj1_study2.remove_from_extraction_form_junction
        end
    end
end
