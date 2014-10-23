# == Schema Information
#
# Table name: projects
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  description         :text
#  notes               :text
#  funding_source      :string(255)
#  creator_id          :integer
#  is_public           :boolean          default(FALSE)
#  created_at          :datetime
#  updated_at          :datetime
#  contributors        :text
#  methodology         :text
#  management_file_url :string(255)
#

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
    # to completely disable instantiated fixtures:
    self.use_instantiated_fixtures = true

    # to keep the fixture instance (@web_sites) available, but do not automatically 'find' each instance:
    #self.use_instantiated_fixtures = :no_instances

    #test "web_site_count" do
    # assert_equal 3, Project.count
    #end

    # test that the project saves
    test "full project should save successfully" do
        proj = Project.new(@full_project.attributes)
        assert proj.save, "Saved the project with all attributes."
    end

    # test that a project without a title will not save successfully
    test "should not save project without a title" do
        proj = Project.new(@missing_title.attributes)
        assert !proj.save, "Saved the project without a title"
    end

    # test the get_status_string method
    test "status string should say public" do
        assert_equal "Complete (Public)", Project.get_status_string(@full_project.id)
    end

    # test the get_status_string method
    test "status string should say private" do
        assert_equal "Incomplete (Private)", Project.get_status_string(@missing_title.id)
    end

    # test the get_studies method
    test "should get two study objects" do
        assert_equal 2, Project.get_studies(@full_project.id).length, "Reporting the wrong number of studies"
    end

    # test the get_num_studies method
    test "should have two studies" do
        assert_equal 2, Project.get_num_studies(@full_project), "Reporting the wrong number of studies"
    end

    # test the get_num_key_qs method
    test "should have two key questions" do
        assert_equal 2, Project.get_num_key_qs(@full_project), "get_num_key_qs not working correctly"
    end

    # test the all_key_questions_accounted_for method
    test "all questions should be accounted for" do
        assert @full_project.all_key_questions_accounted_for
    end

    # test the get_project_leads_string method
    test "should get Chris Parkin as project lead" do
        assert_equal "Chris Parkin", Project.get_project_leads_string(@full_project.id)
    end

    # test the get_project_collabs_string method
    test "should return collaborators named Colla Borator and Colla BoratorTwo" do
        assert_equal "Colla Borator and Colla BoratorTwo", Project.get_project_collabs_string(@full_project.id)
    end

    # test the has_extraction_form_options method
    test "should have extraction forms" do
        assert @full_project.has_extraction_form_options
    end

    # test the has_extraction_form_options method
    test "shouldnt have extraction forms" do
        assert !@empty_project.has_extraction_form_options
    end

    # test the get_num_ext_forms method
    test "should have three extraction forms" do
        assert_equal 3, Project.get_num_ext_forms(@full_project)
    end

    # test the get_num_kqs_with_ext_forms method
    test "should return 2 kqs with efs" do
        assert_equal 2, Project.get_num_kqs_with_ext_forms(@full_project)
    end

    # test the get_num_kqs_without_ext_forms method
    test "should return 0 kqs without efs" do
        assert_equal 0, Project.get_num_kqs_without_ext_forms(@full_project)
    end

    # test the all_kqs_have_extforms method
    test "should return that all kqs have efs" do
        assert Project.all_kqs_have_extforms(@full_project)
    end

    # test that projects can be destroyed
    test "should be deleted successfully" do
        assert_difference('Project.count', -1) do
            @empty_project.destroy
        end
    end

end
