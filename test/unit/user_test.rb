# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      not null
#  email              :string(255)      not null
#  fname              :string(255)      not null
#  lname              :string(255)      not null
#  organization       :string(255)      not null
#  user_type          :string(255)      not null
#  crypted_password   :string(255)      not null
#  password_salt      :string(255)      not null
#  persistence_token  :string(255)      not null
#  login_count        :integer          default(0), not null
#  failed_login_count :integer          default(0), not null
#  last_request_at    :datetime
#  current_login_at   :datetime
#  last_login_at      :datetime
#  current_login_ip   :string(255)
#  last_login_ip      :string(255)
#  perishable_token   :string(255)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
    self.use_instantiated_fixtures = true

    # test username_exists
    test "should return true if username exists and false otherwise" do
        assert User.username_exists("proj_lead")
        assert !User.username_exists("project_leader")
    end

    # test email_exists
    test "should return true if email exists and false otherwise" do
        assert User.email_exists("chris.d.parkin@gmail.com")
        assert !User.email_exists("cparkin@tuftsmedicalcenter.org")
    end

    # test user_has_roles
    test "true if any roles have been defined, false otherwise" do
        assert User.user_has_roles(@project_lead, @full_project.id)
        assert !User.user_has_roles(@project_lead, @missing_title.id)
    end

    # test current_user_has_project_edit_privilege
    test "should be true if user is admin or is project lead and false otherwise" do
        assert User.current_user_has_project_edit_privilege(1, @project_lead)     # lead
        assert !User.current_user_has_project_edit_privilege(1, @project_collab_1) # collaborator
        assert User.current_user_has_project_edit_privilege(1, @another_user)     # admin
    end

    # test has study edit privilege
    test "should return true unless no roles defined for the project" do
        assert User.current_user_has_study_edit_privilege(1, @project_lead) # lead
        assert !User.current_user_has_study_edit_privilege(2, @project_lead) # nothing
        assert User.current_user_has_study_edit_privilege(1, @project_collab_1) #collaborator
        assert User.current_user_has_study_edit_privilege(1,@another_user)     # admin
    end

    # test has_extraction_form_edit_privilege
    test "should return true if user is admin or project creator" do
        assert User.current_user_has_extraction_form_edit_privilege(1, @another_user) # admin
        assert User.current_user_has_extraction_form_edit_privilege(1, @project_lead) # ef creator
        assert !User.current_user_has_extraction_form_edit_privilege(1, @project_collab_1) #collaborator
    end

    # test current_user_has_new_project_privilege
    test "should return true unless the user is nil or not a member" do
        emptyUser = nil
        assert !User.current_user_has_new_project_privilege(emptyUser) # nil user
        assert !User.current_user_has_new_project_privilege(@non_member) # not a member or admin
        assert User.current_user_has_new_project_privilege(@project_collab_1) # member
        assert User.current_user_has_new_project_privilege(@another_user) # admin
    end

    # test get_user_lead_roles
    test "should return one object for project lead and nil for collaborator" do
        assert_equal 1, User.get_user_lead_roles(@project_lead).length
        assert_equal "UserProjectRole", User.get_user_lead_roles(@project_lead).first.class.name
        assert_equal nil, User.get_user_lead_roles(@project_collab_1)
    end

    # test get_user_lead_projects
    test "should return an array of project objects for the project lead and nil otherwise" do
        assert_equal 1, User.get_user_lead_projects(@project_lead).length
        assert_equal "Project", User.get_user_lead_projects(@project_lead).first.class.name
        assert_equal nil, User.get_user_lead_projects(@project_collab_1)
    end

    # test get_user_editor_roles
    test "should return the roles objects where a user is editor" do
        assert_equal nil, User.get_user_editor_roles(@project_lead) # lead doesn't have any
        assert_equal 1, User.get_user_editor_roles(@project_collab_1).length
        assert_equal "UserProjectRole",User.get_user_editor_roles(@project_collab_1).first.class.name
    end

    #test get_user_editor_projects
    test "should return an array of projects that the user can edit" do
        assert_equal 1, User.get_user_editor_projects(@project_collab_2).length
        assert_equal "Project", User.get_user_editor_projects(@project_collab_2).first.class.name
        assert_equal nil, User.get_user_editor_projects(@non_member)
        assert_equal nil, User.get_user_editor_projects(@project_lead)
    end

    # test get_name
    test "should return Chris Parkin" do
        assert_equal "Chris Parkin", User.get_name(@project_lead.id)
        assert_equal "Non Member", User.get_name(@non_member.id)
    end

    # test get_users_for_project
    test "should return all users on the project not including the current user" do
        assert_equal 2, User.get_users_for_project(1,@project_lead).length
        assert_equal "UserProjectRole", User.get_users_for_project(1,@project_lead).first.class.name
        user1 = User.get_users_for_project(1,@project_lead).first.user_id
        name = User.get_name(user1)
        assert_equal "Colla Borator", name
    end

end
