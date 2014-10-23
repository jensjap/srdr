require 'spec_helper'

DatabaseCleaner.strategy = :truncation

describe "Extraction Form pages" do

  subject { page }

  before(:all) do
    @lead                         = FactoryGirl.create(:user, login: "lead", email: "lead@factory.com")
    @member                       = FactoryGirl.create(:user, login: "user", email: "user@factory.com")

    @user_org_role_lead           = FactoryGirl.create(:user_organization_role, user_id: @lead.id)
    @user_org_role_user           = FactoryGirl.create(:user_organization_role, user_id: @member.id)

    @project1                     = FactoryGirl.create(:project)
    @project2                     = FactoryGirl.create(:project, title: "rspect test project 2", creator_id: 0)
    @public_project               = FactoryGirl.create(:project, title: "rspect test project 3", creator_id: 0, is_public: 1)

    @user_project_role_lead       = FactoryGirl.create(:user_project_role, user_id: @lead.id, project_id: @project1.id, role: "lead")
    @user_project_role_user       = FactoryGirl.create(:user_project_role, user_id: @member.id, project_id: @project1.id, role: "editor")

    @extraction_form_proj_1       = FactoryGirl.create(:extraction_form, creator_id: 1, project_id: @project1.id)
    @extraction_form_proj_2       = FactoryGirl.create(:extraction_form, creator_id: 1, project_id: @project2.id)
    @extraction_form_proj_public  = FactoryGirl.create(:extraction_form, creator_id: 1, project_id: @public_project.id)

    @key_question                 = FactoryGirl.create(:key_question)

    @extraction_form_key_question = FactoryGirl.create(:extraction_form_key_question)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe "Non-published project's extraction form" do

    describe "Project lead should edit extraction form" do

      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}/edit"
      end

      it { should have_selector('h3', text: "Editing Extraction Form") }
      it { should_not have_selector('div.alert') }
    end

    describe "Project lead should see extraction form" do

      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}"
      end

      #it { should have_selector('div.summary_heading', text: "Key Questions") }
      #it { should have_selector('div.summary_heading', text: "Arm Name Suggestions") }
      #it { should have_selector('div.summary_heading', text: "Design Details and Enrollment") }
      #it { should have_selector('div.summary_heading', text: "Baseline Characteristics Fields") }
      #it { should have_selector('div.summary_heading', text: "Outcome Name Suggestions") }
      #it { should have_selector('div.summary_heading', text: "Adverse Events") }
      it { should_not have_selector('div.alert') }
    end

    describe "Project member should not edit extraction form, but redirect to add study instead" do

      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}/edit"
      end

      it { should have_selector('h3', text: "Add Studies") }
    end

    describe "Project member should see extraction form" do

      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}"
      end

      #it { should have_selector('div.summary_heading', text: "Key Questions") }
      #it { should have_selector('div.summary_heading', text: "Arm Name Suggestions") }
      #it { should have_selector('div.summary_heading', text: "Design Details and Enrollment") }
      #it { should have_selector('div.summary_heading', text: "Baseline Characteristics Fields") }
      #it { should have_selector('div.summary_heading', text: "Outcome Name Suggestions") }
      #it { should have_selector('div.summary_heading', text: "Adverse Events") }
      it { should_not have_selector('div.alert') }
      it { should_not have_link('edit') }
    end

    describe "Visitor should not edit extraction form" do
      before do
        visit logout_path
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}/edit"
      end

      it { should have_selector('div.alert') }
    end

    describe "Visitor should not see extraction form" do
      before do
        visit logout_path
        visit "/projects/#{@project1.id}/extraction_forms/#{@extraction_form_proj_1.id}"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member should not see extraction form" do
      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@project2.id}/extraction_forms/#{@extraction_form_proj_2.id}"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member should not edit extraction form" do
      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@project2.id}/extraction_forms/#{@extraction_form_proj_2.id}/edit"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member lead should not see extraction form" do
      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@project2.id}/extraction_forms/#{@extraction_form_proj_2.id}"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member lead should not edit extraction form" do
      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@project2.id}/extraction_forms/#{@extraction_form_proj_2.id}/edit"
      end

      it { should have_selector('div.alert') }
    end
  end

  describe "Published project's extraction form" do

    describe "Project non-member lead should not edit extraction form" do
      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}/edit"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member lead should see extraction form" do
      before do
        visit logout_path
        sign_in @lead
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}"
      end

      it { should_not have_selector('div.alert') }
    end

    describe "Project non-member should not edit extraction form" do
      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}/edit"
      end

      it { should have_selector('div.alert') }
    end

    describe "Project non-member should see extraction form" do
      before do
        visit logout_path
        sign_in @member
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}"
      end

      it { should_not have_selector('div.alert') }
    end

    describe "Visitor should not edit extraction form" do
      before do
        visit logout_path
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}/edit"
      end

      it { should have_selector('div.alert') }
    end

    describe "Visitor should see extraction form" do
      before do
        visit logout_path
        visit "/projects/#{@public_project.id}/extraction_forms/#{@extraction_form_proj_public.id}"
      end

      it { should_not have_selector('div.alert') }
    end
  end
end
