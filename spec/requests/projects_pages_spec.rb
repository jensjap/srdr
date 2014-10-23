require 'spec_helper'

DatabaseCleaner.strategy = :truncation

describe "Project pages" do

  subject { page }

  before(:all) do
    @user           = FactoryGirl.create(:user)
    @user_org_role  = FactoryGirl.create(:user_organization_role)
    @project1       = FactoryGirl.create(:project)
    @project2       = FactoryGirl.create(:project, title: "rspect test project 2", creator_id: 0)
    @public_project = FactoryGirl.create(:project, title: "rspect test project 3", creator_id: 0, is_public: 1)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "index" do

    describe "signed-in user should see project index page" do

      before do
        visit logout_path
        sign_in @user
        visit root_path
      end

      it { should have_link("Log Out") }
      it { should_not have_link("Login") }
    end

    describe "visitor should not see project index page" do

      before do
        visit logout_path
        visit "/projects"
      end

      it { should have_selector('div.alert', text: "You must be logged in to access this page") }
    end
  end

  describe "non-published project summary page" do

    describe "user that belongs to the project should see the project summary" do
      before do
        visit logout_path
        sign_in @user
        visit '/projects/1'
      end

      it { should have_selector('h1', text: "Project") }
      it { should have_selector('h3', text: "Project Summary") }
    end

    describe "non-member user should not see project summary" do
      before do
        visit logout_path
        sign_in @user
        visit '/projects/2'
      end

      it { should_not have_selector('h1', text: "Project") }
      it { should have_selector('div.alert') }
    end

    describe "non-member should not edit a project" do
      before do
        visit logout_path
        sign_in @user
        visit "/projects/#{@project2.id}/edit"
      end

      it { should have_selector('div.alert', text: "You have not been granted access to this resource") }
    end

    describe "visitor should not see project summary" do
      before do
        visit logout_path
        visit '/projects/2'
      end

      it { should_not have_selector('h1', text: "Project") }
    end
  end

  describe "published projects" do

    describe "published project is accessible by visitor" do
      before do
        visit logout_path
        visit '/projects/3'
      end

      it { should have_selector('h1', text: "Project") }
    end

    describe "published project is accessible by user" do
      before do
        visit logout_path
        sign_in @user
        visit '/projects/3'
      end

      it { should have_selector('h1', text: "Project") }
    end
  end

end
