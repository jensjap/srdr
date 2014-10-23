require "spec_helper"

DatabaseCleaner.strategy = :truncation

describe "Authentication Pages" do

    subject { page }

    before(:all) do
        @user = FactoryGirl.create(:user)
        @user_org_role = FactoryGirl.create(:user_organization_role, user_id: @user.id)
    end

    after(:all) do
        DatabaseCleaner.clean
    end

    describe "MyProject pages" do
        before do
            visit logout_path
            visit root_path
            fill_in "user_session_login", with: @user.login
            fill_in "user_session_password", with: @user.password
            click_button "Log In"
        end

        it { should_not have_link('Login') }
        it { should have_link('Log Out') }
        it { should have_content('MY WORK') }

        describe "Create new project", js: true do
            before do
                visit projects_path

                click_link("Create a New Project")

                fill_in "project[title]",             with: "rspec test project 1"
                fill_in "Project Description:",       with: "This is a test project"
                fill_in "Contributor(s):",            with: "testerbot"
                fill_in "Methodology Description:",   with: "My methods"
                fill_in "Project Notes",              with: "Some notes"
                fill_in "Funding Source:",            with: "Lots-o-money corp"

                click_button('Add Key Question')
                fill_in "key_question[question]",     with: "My important question"
                sleep 1
                click_button("Save")
                sleep 1
                click_button("SAVE")
                # Need to wait a little bit. JavaScript seems to be lagging behind
                # on removing the un-saved tags after having pressed "SAVE"
                sleep 2
            end

            it { should_not have_selector('error') }
        end
    end
end
