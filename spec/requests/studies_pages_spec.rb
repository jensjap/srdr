require 'spec_helper'

DatabaseCleaner.strategy = :truncation

describe "Studies Pages" do  #{{{1

  subject { page }

  before(:all) do  #{{{2
     # User Logins
     @alpha_lead_1                                = FactoryGirl.create(:user, login: 'alpha_lead_1',   email: 'alpha_lead_1@factory.com')
     @alpha_editor_1                              = FactoryGirl.create(:user, login: 'alpha_editor_1', email: 'alpha_editor_1@factory.com')
     @beta_lead_1                                 = FactoryGirl.create(:user, login: 'beta_lead_1',    email: 'beta_lead_1@factory.com')
     @beta_editor_1                               = FactoryGirl.create(:user, login: 'beta_editor_1',  email: 'beta_editor_1@factory.com')

     # Projects
     @project_1                                   = FactoryGirl.create(:project, title: "rspec test project 1", creator_id: @alpha_lead_1.id)
     @project_2                                   = FactoryGirl.create(:project, title: "rspec test project 2", creator_id: @beta_lead_1.id)
     @project_3                                   = FactoryGirl.create(:project, title: "Published Project",    creator_id: @beta_lead_1.id, is_public: 1)

     # User Organization Role
     @uor_alpha_team_lead_1                       = FactoryGirl.create(:user_organization_role, user_id: @alpha_lead_1.id)
     @uor_alpha_team_editor_1                     = FactoryGirl.create(:user_organization_role, user_id: @alpha_editor_1.id)
     @uor_beta_team_lead_1                        = FactoryGirl.create(:user_organization_role, user_id: @beta_lead_1.id)
     @uor_beta_team_editor_1                      = FactoryGirl.create(:user_organization_role, user_id: @beta_editor_1.id)

     # User Project Role
     @upr_alpha_team_lead_1_project_1             = FactoryGirl.create(:user_project_role, user_id: @alpha_lead_1.id,   project_id: @project_1.id, role: "lead")
     @upr_alpha_team_editor_1_project_1           = FactoryGirl.create(:user_project_role, user_id: @alpha_editor_1.id, project_id: @project_1.id, role: "editor")
     @upr_beta_team_lead_1_project_2              = FactoryGirl.create(:user_project_role, user_id: @beta_lead_1.id,    project_id: @project_2.id, role: "lead")
     @upr_beta_team_editor_1_project_2            = FactoryGirl.create(:user_project_role, user_id: @beta_editor_1.id,  project_id: @project_2.id, role: "editor")
     @upr_beta_team_lead_1_project_3              = FactoryGirl.create(:user_project_role, user_id: @beta_lead_1.id,    project_id: @project_3.id, role: "lead")

     # Key Question
     @kq1_project_1                               = FactoryGirl.create(:key_question, project_id: @project_1.id)
     @kq1_project_2                               = FactoryGirl.create(:key_question, project_id: @project_2.id)
     @kq1_project_3                               = FactoryGirl.create(:key_question, project_id: @project_3.id)

     # Extraction Form
     @ef1_project_1                               = FactoryGirl.create(:extraction_form, creator_id: @alpha_lead_1.id, project_id: @project_1.id)
     @ef1_project_2                               = FactoryGirl.create(:extraction_form, creator_id: @beta_lead_1.id,  project_id: @project_2.id)
     @ef1_project_3                               = FactoryGirl.create(:extraction_form, creator_id: @beta_lead_1.id,  project_id: @project_3.id)

     # Study
     @study1_project_1                            = FactoryGirl.create(:study, project_id: @project_1.id, creator_id: @alpha_lead_1.id)
     @study1_project_2                            = FactoryGirl.create(:study, project_id: @project_2.id, creator_id: @beta_lead_1.id)
     @study2_project_2                            = FactoryGirl.create(:study, project_id: @project_2.id, creator_id: @beta_editor_1.id)
     @study1_project_3                            = FactoryGirl.create(:study, project_id: @project_3.id, creator_id: @beta_lead_1.id)

     # Study Extraction Form Association
     @study1_project_1_ef1_project_1              = FactoryGirl.create(:study_extraction_form, study_id: @study1_project_1.id, extraction_form_id: @ef1_project_1.id)
     @study1_project_2_ef1_project_2              = FactoryGirl.create(:study_extraction_form, study_id: @study1_project_2.id, extraction_form_id: @ef1_project_2.id)
     @study2_project_2_ef1_project_2              = FactoryGirl.create(:study_extraction_form, study_id: @study2_project_2.id, extraction_form_id: @ef1_project_2.id)
     @study1_project_3_ef1_project_3              = FactoryGirl.create(:study_extraction_form, study_id: @study1_project_3.id, extraction_form_id: @ef1_project_3.id)

     # Extraction Form Key Question Association
     @ef1_project_1_kq1_project_1                 = FactoryGirl.create(:extraction_form_key_question, extraction_form_id: @ef1_project_1.id, key_question_id: @kq1_project_1.id)
     @ef1_project_2_kq1_project_2                 = FactoryGirl.create(:extraction_form_key_question, extraction_form_id: @ef1_project_2.id, key_question_id: @kq1_project_2.id)
     @ef1_project_3_kq1_project_3                 = FactoryGirl.create(:extraction_form_key_question, extraction_form_id: @ef1_project_3.id, key_question_id: @kq1_project_3.id)
  end

  after(:all) do  #{{{2
    DatabaseCleaner.clean
  end

  describe "Logging in" do  #{{{2
    before do
      visit root_path
      fill_in "Username", with: @alpha_lead_1.login
      fill_in "Password", with: @alpha_lead_1.password
      click_button "Log In"
    end

    it { should_not have_link("Login") }

    describe "Navigate away from Project's edit page without changes" do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        visit root_path
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to the project title", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Project Title", with: "New Title"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to the project description", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Project Description", with: "New Description"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to contributors", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Contributor", with: "New Contributor"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to methodology description", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Methodology Description", with: "New Methodology"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to project notes", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Project Notes", with: "New Project Notes"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Navigate away from Project's edit page with changes to funding source", js: true do  #{{{3
      before do
        visit '/projects/' + @project_1.id.to_s + '/edit'
        fill_in "Funding Source", with: "New Funding Source"
        visit root_path
        sleep 1
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end

      its(:source) { should have_selector('title', text: full_title('Home'))}
    end

    describe "Add a study", js: true do  #{{{3
      before do
        visit "/projects/" + @project_1.id.to_s + "/studies/new"
        find(:css, "#study_type_study_number_single").set(true)
        sleep 1
        find(:css, "#study_key_question_1").set(true)
        sleep 1
        click_button "Save And Continue"
        sleep 1
      end

      it { should have_content('Success!')}
    end
  end

  describe "Visiting Study Pages" do  #{{{2

    describe "As a project leader" do  #{{{3

      before do
        visit logout_path
        sign_in @alpha_lead_1
      end

      describe "Project lead's access to his own studies" do  #{{{4
    
        describe "Project lead should see study index page" do

          before { visit "/projects/#{@project_1.id}/studies/" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('h3', text: "Add Studies to this Project") }
        end
    
        describe "Project lead should see study page" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('div.summary_heading', text: "Study Title and Description") }
          it { should have_selector('div.summary_heading', text: "Key Questions Addressed") }
          it { should have_selector('div.summary_heading', text: "Primary Publication Information") }
          it { should have_selector('div.summary_heading', text: "Secondary Publication Information") }
          it { should have_selector('span.summary_heading', text: "Extraction Form") }
          it { should have_selector('div.summary_heading', text: "Results & Comparisons") }
        end
    
        describe "Project lead should edit study pages" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}/edit" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('h3', text: "Editing Study") }
        end
      end #describe "Project lead's access to his own studies" do

      describe "Project lead's access to someone else's studies" do  #{{{4
  
        describe "Project lead should not see someone else's study index" do

          before { visit "/projects/#{@project_2.id}/studies/" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
    
        describe "Project lead should not see someone else's study page" do

          before { visit "/projects/#{@project_2.id}/studies/#{@study1_project_2.id}" }
    
          it { should have_selector('div.alert', text: "The resource you are attempting to access has not been made public") }
        end

        describe "Project lead should not edit someone else's study pages" do

          before { visit "/projects/#{@project_2.id}/studies/#{@study1_project_2.id}/edit" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
      end #describe "Project lead's access to someone else's studies" do

      describe "Project lead's access to published studies" do  #{{{4

        describe "Project lead should see published studies" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}" }

          it { should_not have_selector('div.alert') }
          it { should have_selector('div.summary_heading',  text: "Study Title and Description") }
          it { should have_selector('div.summary_heading',  text: "Key Questions Addressed") }
          it { should have_selector('div.summary_heading',  text: "Primary Publication Information") }
          it { should have_selector('div.summary_heading',  text: "Secondary Publication Information") }
          it { should have_selector('span.summary_heading', text: "Extraction Form") }
          it { should have_selector('div.summary_heading',  text: "Results & Comparisons") }
        end

        describe "Project lead should not edit published studies" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}/edit" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('span#study_citation', text: "PubMed ID") }
        end
      end #describe "Project lead's access to published studies" do
    end #describe "As a project leader" do

    describe "As project member" do  #{{{3
      before do
        visit logout_path
        sign_in @alpha_editor_1
      end

      #!!! This is not testing whether the study is assigned to this editor
      describe "Project members's access to his own studies" do  #{{{4
    
        describe "Project member should see study index page" do

          before { visit "/projects/#{@project_1.id}/studies/" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('h3', text: "Add Studies to this Project") }
        end
    
        describe "Project member should see study page" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('div.summary_heading', text: "Study Title and Description") }
          it { should have_selector('div.summary_heading', text: "Key Questions Addressed") }
          it { should have_selector('div.summary_heading', text: "Primary Publication Information") }
          it { should have_selector('div.summary_heading', text: "Secondary Publication Information") }
          it { should have_selector('span.summary_heading', text: "Extraction Form") }
          it { should have_selector('div.summary_heading', text: "Results & Comparisons") }
        end
    
        describe "Project member should edit study pages" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}/edit" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('h3', text: "Editing Study") }
        end
      end #describe "Project member's access to his own studies" do

      describe "Project member's access to someone else's studies" do  #{{{4
  
        describe "Project member should not see someone else's study index" do

          before { visit "/projects/#{@project_2.id}/studies/" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
    
        describe "Project member should not see someone else's study page" do

          before { visit "/projects/#{@project_2.id}/studies/#{@study1_project_2.id}" }
    
          it { should have_selector('div.alert', text: "The resource you are attempting to access has not been made public") }
        end

        describe "Project  lead should not edit someone else's study pages" do

          before { visit "/projects/#{@project_2.id}/studies/#{@study1_project_2.id}/edit" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
      end #describe "Project member's access to someone else's studies" do

      describe "Project member's access to published studies" do  #{{{4

        describe "Project member should see published studies" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}" }

          it { should_not have_selector('div.alert') }
          it { should have_selector('div.summary_heading',  text: "Study Title and Description") }
          it { should have_selector('div.summary_heading',  text: "Key Questions Addressed") }
          it { should have_selector('div.summary_heading',  text: "Primary Publication Information") }
          it { should have_selector('div.summary_heading',  text: "Secondary Publication Information") }
          it { should have_selector('span.summary_heading', text: "Extraction Form") }
          it { should have_selector('div.summary_heading',  text: "Results & Comparisons") }
        end

        describe "Project member should not edit published studies" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}/edit" }

          it { should have_selector('div#content', text: "You do not have access to this information. Please contact your project lead to correct this problem") }
          it { should_not have_selector('span#study_citation', text: "PubMed ID") }
        end
      end #describe "Project member's access to published studies" do
    end #describe "As project member" do

    #!!!
    describe "As visitor" do  #{{{3
      before do
        visit logout_path
      end

      describe "Visitor's access to un-published studies" do  #{{{4
    
        describe "Visitor should not see study index page" do

          before { visit "/projects/#{@project_1.id}/studies/" }
    
          it { should have_selector('div.alert', text: "You must be logged in to access this page") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
    
        describe "Visitor should not see study page" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}" }
    
          it { should have_selector('div.alert', text: "You must be logged in to access this page") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
    
        describe "Visitor should not edit study pages" do

          before { visit "/projects/#{@project_1.id}/studies/#{@study1_project_1.id}/edit" }
    
          it { should have_selector('div.alert', text: "You must be logged in to access this page") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
      end #describe "Visitor's access to un-published studies" do

      describe "Visitor's access to published studies" do  #{{{4
  
        describe "Visitor should see published study page" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}" }
    
          it { should_not have_selector('div.alert') }
          it { should have_selector('div.summary_heading',  text: "Study Title and Description") }
          it { should have_selector('div.summary_heading',  text: "Key Questions Addressed") }
          it { should have_selector('div.summary_heading',  text: "Primary Publication Information") }
          it { should have_selector('div.summary_heading',  text: "Secondary Publication Information") }
          it { should have_selector('span.summary_heading', text: "Extraction Form") }
          it { should have_selector('div.summary_heading',  text: "Results & Comparisons") }
        end

        describe "Visitor should not edit published study pages" do

          before { visit "/projects/#{@project_3.id}/studies/#{@study1_project_3.id}/edit" }

          it { should have_selector('div.alert', text: "You must be logged in to access this page") }
          it { should_not have_selector('td', text: "PubMed ID") }
        end
      end #describe "Visitor's access to published studies" do
    end #describe "As Visitor" do
  end #describe "Visiting Study Pages" do
end
