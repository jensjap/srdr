# encoding: UTF-8

require 'spec_helper'

describe "StaticPages" do

    describe "visiting the root url ('/' or '/home/index')" do
        before { visit root_path }

        subject { page }

        it { should have_selector('title', text: full_title('Home')) }

        it "should have login window" do
            should have_selector(
                'div#login-div',
                text: 'Registered users, log in below:')
        end

        it "should have summary of recently completed and deposited data" do
            should have_selector(
                'h2',
                text: 'Recently Completed and Deposited Reports Data')
        end

        describe "AHRQ links in the root page header" do
            it "should have a link to US Dept. of Human Health Services" do
                should have_link(
                    'U.S. Department of Health and Human Services',
                    href: 'http://www.hhs.gov/')
            end

            it "should have a link to Agency for Healthcare Research Quality" do
                should have_link(
                    'Agency for Healthcare Research Quality',
                    href: 'http://www.ahrq.gov/')
            end

            describe "links in the AHRQ banner" do
                it "should have a link to AHRQ Home" do
                    should have_link(
                        'AHRQ Home',
                         ref: 'http://www.ahrq.gov')
                end

                it "should have a link to Questions?" do
                    should have_link(
                        'Questions',
                        href: 'https://info.ahrq.gov/cgi-bin/ahrq.cfg/php/'\
                              'enduser/std_alp.php')
                end

                it "should have a link to Contact Us" do
                    should have_link(
                        'Contact Us',
                        href: 'http://www.ahrq.gov/info/customer.htm')
                end

                it "should have a link to Site Map" do
                    should have_link(
                        'Site Map',
                        href: 'http://www.ahrq.gov/sitemap.htm')
                end

                it "should have a link to What's new" do
                    should have_link(
                        "What's New",
                        href: 'http://www.ahrq.gov/whatsnew.htm')
                end

                it "should have a link to Browse" do
                    should have_link(
                        'Browse',
                        href: 'http://www.ahrq.gov/browse/')
                end

                it "should have a link to Informacion en espanol" do
                    should have_link(
                        'Información en español',
                        href: 'http://www.ahrq.gov/consumer/espanoix.htm')
                end

                it "should have a link to the E-mail subscription page" do
                    should have_link(
                        'E-mail Updates',
                        href: 'https://subscriptions.ahrq.gov/service/'\
                              'multi_subscribe.html?code=USAHRQ')
                end
            end # describe "links in the AHRQ banner" do

        end # describe "AHRQ links in the root page header" do

        describe "SRDR navigation links on the root page" do
            it "should have a link to 'Try the SRDR Training Site'" do
                should have_link(
                    'Try the SRDR Training Site',
                    href: 'http://srdr.training.ahrq.gov')
            end

            it "should have a link to the login page" do
                should have_link(
                    'Login', href: login_path)
            end

            it "should have a link to the register page" do
                should have_link(
                    'Register', href: register_path)
            end

            it "should have a link to the feedback page" do
                should have_link(
                    'Feedback', href: '#')
            end

            it "should have a link to the help & training page" do
                should have_link(
                    'Help & Training', href: help_path)
            end

            it "should have a link to the contact page" do
                should have_link(
                    'Contact Us', href: help_path(selected: 6))
            end

            it "should have a link to the usage policy page" do
                should have_link(
                    'Usage Policies', href: home_policies_path)
            end
        end # describe "Navigation links on the root page" do

        describe "SRDR horizontal-navigation elements" do
            it "should have list item 'Home'" do
                should have_selector('li.current', text: 'Home')
                should have_selector('li.horizontal-nav-link', text: 'Home')
            end

            it "should have list item 'Published Projects'" do
                should have_selector('li.horizontal-nav-link', text: 'Published Projects')
            end
        end # describe "SRDR horizontal-navigation elements" do

        describe "AHRQ footer in the root page" do
            it "should have a link to the AHRQ Home page" do
                should have_link(
                    'AHRQ Home',
                    href: 'http://www.ahrq.gov')
            end

            it "should have a link to the AHRQ Questions page" do
                should have_link(
                    'Questions?',
                    href: 'https://info.ahrq.gov/cgi-bin/ahrq.cfg'\
                          '/php/enduser/std_alp.php')
            end

            it "should have a link to the AHRQ Contact Page" do
                should have_link(
                    'Contact AHRQ',
                    href: 'http://www.ahrq.gov/info/customer.htm')
            end

            it "should have a link to the AHRQ Site map" do
                should have_link(
                    'Site Map',
                    href: 'http://www.ahrq.gov/sitemap.htm')
            end

            it "should have a link to the AHRQ Accessibility page" do
                should have_link(
                    'Accessibility',
                    href: 'http://www.ahrq.gov/accessibility.htm')
            end

            it "should have a link to the AHRQ Privacy Policy page" do
                should have_link(
                    'Privacy Policy',
                    href: 'http://www.ahrq.gov/news/privacy.htm')
            end

            it "should have a link to the Freedom of Information Act page" do
                should have_link(
                    'Freedom of Information Act',
                    href: 'http://www.ahrq.gov/news/foia.htm')
            end

            it "should have a link to the AHRQ Dislcaimer page" do
                should have_link(
                    'Disclaimers',
                    href: 'http://www.ahrq.gov/news/disclaim.htm')
            end

            it "should have a link to the AHRQ Plain Writing Act" do
                should have_link(
                    'Plain Writing Act',
                    href: 'http://www.hhs.gov/open/recordsandreports/'\
                          'plainwritingact/index.html')
            end

            it "should have a link to the U.S. Dept. of Health & Human "\
               "services" do
                should have_link(
                    'U.S. Department of Health & Human Services',
                    href: 'http://www.hhs.gov/')
            end

            it "should have a link to the White House Home page" do
                should have_link(
                    'The White House',
                    href: 'http://www.whitehouse.gov/')
            end

            it "should have a link to the U.S. Government Web Portal" do
                should have_link(
                    "USA.gov: The U.S. Government's Official Web Portal",
                    href: 'http://www.usa.gov/')
            end
        end # describe "AHRQ link in the root page footer" do
    end # describe "visiting the root url ('/' or '/home/index')" do

    describe "visiting the 'Login' page" do
        before { visit login_path }

        subject { page }

        it { should have_selector('title', text: full_title('Login')) }
        it { should have_selector('h1', text: 'Log in to SRDR') }

        describe "with invalid information" do
            before { click_button "Log In"}

            it { should have_selector('title', text: full_title('Login')) }
            it { should have_selector('div.alert-error', text: 'Invalid login') }

            describe "after visiting another page" do
                before { click_link "Register"}
                it { should_not have_selector('div.error') }
            end
        end

        #describe "with valid information" do
        #    let(:user) { FactoryGirl.create(:user) }
        #    before { sign_in user }

        #    it { should_not have_selector('title', text: '|') }
        #    it { should_not have_link('Login', href: login_path) }
        #end
    end # describe "visiting the login url" do

    describe "visiting the 'Register' page" do
        before { visit register_path }

        subject { page }

        it { should have_selector('title', text: full_title('Registration')) }
        it { should have_selector('h1',
                                  text: 'Create A New SRDR User Account') }
        it { body.should include('Want to try SRDR before registering?') }

        describe "without agreeing to the SRDR Usage Policies" do
            before do
                fill_in "Username",         with: 'testerbot'
                fill_in "First Name",       with: 'tester'
                fill_in "Last Name",        with: 'bot'
                fill_in "Organization",     with: 'Test Inc.'
                fill_in "Email",            with: 'tester@bot.com'
                fill_in "Password",         with: 'testerbot'
                fill_in "Confirm Password", with: 'testerbot'
                click_button "Submit"
            end

            it { should have_selector('h1',
                                      text: 'New SRDR User Account Denied') }
            it { should have_selector('div.alert-error',
                    text: 'You must agree to the SRDR Usage Policies') }
        end # describe "without agreeing to the SRDR Usage Policies" do

        describe "agree to SRDR Usage Policy but with invalid information" do
            before do
                find("#user_agreement").set(true)
                click_button "Submit"
            end

            it { should have_selector('div.alert') }
            it { should have_selector('h1',
                    text: 'Create A New SRDR User Account - ERROR') }
        end # describe "agree to SRDR Usage Policy but with invalid information" do

        describe "with valid information" do
            before do
                fill_in "Username",         with: 'testerbot'
                fill_in "First Name",       with: 'tester'
                fill_in "Last Name",        with: 'bot'
                fill_in "Organization",     with: 'Test Inc.'
                fill_in "Email",            with: 'tester@bot.com'
                fill_in "Password",         with: 'testerbot'
                fill_in "Confirm Password", with: 'testerbot'
                find("#user_agreement").set(true)
                click_button "Submit"
            end

            it { should have_selector('div.alert-success') }
            it { should have_selector('h1',
                    text: 'New SRDR User Account Registration Confirmation')}
            it { body.should include('Thank you for requesting a new SRDR ' \
                                     'user account.')}
        end # describe "with valid information" do
    end # describe "visiting the 'Register' page" do

    describe "visiting the 'Feedback' page" do
    end

    describe "visiting the 'Help & Training' page", :js => true do
        before { visit help_path }

        subject { page }

        # Problem with capybara and not recognizing title elements because they are invisible? http://stackoverflow.com/a/14873614
        its(:source) { should have_selector('title', text: full_title('Help & Training')) }
        it { should have_selector('h1', text: 'Help & Training') }

        describe "validating 'Training Materials' tab" do
            before { click_link 'Training Materials' }

            it { should have_selector('h1', text: 'Help & Training') }
            it { should have_selector('h2', text: 'SRDR Training Materials') }
            it { should have_selector('h3', text: 'Overview') }
            it { should have_selector('h3', text: 'Downloads') }

            it { should have_link('Free PDF Reader') }
            it { should have_link('Free Word Reader') }

            it { should have_link('Introduction (PDF - 1.1 MB)') }
            it { should have_link('Using Project Tools (Word - 3.6 MB)') }
            it { should have_link('How to Add Questions to an Extraction Form (Word - 3.6 MB)') }

            it { should have_link('Blood Pressure Targets - Full Tutorial (Word - 15.7 MB)') }
            it { should have_link('Blood Pressure Targets - Data Extraction Only (Word - 5.9 MB)') }
            it { should have_link('Diagnostic Tests (Word - 12.1 MB)') }
            it { should have_link('Implantable Cardiac Devices (Word - 17 MB)') }
        end # describe "validating 'Training Materials' tab" do

        describe "validating 'User Manual' tab" do
            before { click_link 'User Manual' }

            it { should have_selector('h2', text: 'The SRDR User Manual') }
            it { should have_selector('h2', text: 'Table of Contents') }
            it { should have_selector('h3', text: 'Introduction') }
            it { should have_selector('h3', text: 'Public Usage') }
            it { should have_selector('h3', text: 'Commentators') }
            it { should have_selector('h3', text: 'Contributors') }
            it { should have_selector('h3', text: 'Contributors: How-To Reference') }

            it { should have_link('What is the SRDR?', href: '#intro1') }
            it { should have_link('User Manual Goals', href: '#intro2') }
            it { should have_link('SRDR Overview', href: '#intro3') }

            it { should have_link('Data Viewing', href: '#public1') }
            it { should have_link('Search', href: '#public2') }

            it { should have_link('Data Viewing', href: '#commentator1') }
            it { should have_link('Search', href: '#commentator2') }
            it { should have_link('Registration', href: '#commentator3') }
            it { should have_link('Commenting', href: '#commentator4') }

            it { should have_link('Data Viewing', href: '#contributor1') }
            it { should have_link('Search', href: '#contributor2') }
            it { should have_link('Registration', href: '#contributor3') }
            it { should have_link('Your Workspace and Basic Navigation', href: '#contributor4') }
            it { should have_link('Help and SRDR Iconography', href: '#contributor5') }

            it { should have_link('Create a Project', href: '#how1') }
            it { should have_link('Edit an Existing Project', href: '#how2') }
            it { should have_link('Add/Edit Users and User Roles', href: '#how3') }
            it { should have_link('Create an Extraction Form', href: '#how4') }
            it { should have_link('Edit an Existing Extraction Form', href: '#how5') }
            it { should have_link('Add a Study', href: '#how6') }
            it { should have_link('Extract a Study', href: '#how7') }
            it { should have_link('Project Tools', href: '#how8') }
        end # describe "validating 'User Manual' tab" do

#        describe "validating 'Cochrane Colloquium 2012' tab" do
#            before { click_link 'Cochrane Colloquium 2012' }
#
#            it { should have_selector('h2', text: 'The Cochrane Colloquium SRDR Workshop') }
#        end # describe "validating 'Cochrane Colloquium 2012' tab" do

        describe "validating 'Video Tutorials' tab" do
            before { click_link 'Video Tutorials' }

            it { should have_selector('h2', text: 'Video Tutorials') }

            it { should have_link('1. SRDR Overview and Project Initiation',
                                  href: 'http://youtu.be/U3Ti12zwdDc') }
            it { should have_link('2. Creating Extraction Form Template in the SRDR',
                                  href: 'http://youtu.be/D5l3np2smHo') }
            it { should have_link('3. Add, View & Edit Study Data in the SRDR Site',
                                  href: 'http://youtu.be/gYXMrpLKzL0') }
            it { should have_link('4. Building Questions for Data Extraction in the SRDR',
                                  href: 'http://youtu.be/CvRPv4XG6Rc') }

            it { should have_selector('a.needs_exit_disclaimer',
                                      text: '1. SRDR Overview and Project Initiation') }
            it { should have_selector('a.needs_exit_disclaimer',
                                      text: '2. Creating Extraction Form Template in the SRDR') }
            it { should have_selector('a.needs_exit_disclaimer',
                                      text: '3. Add, View & Edit Study Data in the SRDR Site') }
            it { should have_selector('a.needs_exit_disclaimer',
                                      text: '4. Building Questions for Data Extraction in the SRDR') }
        end # describe "validating 'Video Tutorials' tab" do

        describe "validating 'Commonly Used Icons' tab" do
            before { click_link 'Commonly Used Icons' }

            it { should have_selector('h2', text: 'Commonly Used Icons') }
            it { body.should have_content('In the Systematic Review Data Repository') }
        end # describe "validating 'Commonly Used Icons' tab" do

        describe "validating 'Frequently Asked Questions' tab" do
            before { click_link 'Frequently Asked Questions' }

            it { should have_selector('h2', text: 'Frequently Asked Questions') }
        end # describe "validating 'Frequently Asked Questions' tab" do

    end # describe "visiting the 'Help & Training' page", :js => true do

    describe "visiting the Contact Us' page" do
        before { visit help_path(selected: 7) }

        subject { page }

        it { should have_selector('title',
                                  text: full_title('Help & Training')) }
        it { should have_selector('h1',
                                  text: 'Help & Training') }
        it { should have_selector('h2',
                                  text: 'For questions and concerns please contact:') }
        it { should have_selector('strong',
                                  text: 'The SRDR Team') }
    end # describe "visiting the Contact Us' page" do

    describe "visiting the 'Usage Policies' page" do
        before { visit '/home/policies' }

        subject { page }

        it { should have_selector('title',
                                  text: full_title('Policies')) }
        it { should have_selector('h2',
                                  text: 'SRDR Usage Policies') }
        it { should have_selector('h3',
                                  text: 'SRDR Comment Policy') }
        it { should have_selector('h3',
                                  text: 'Medical Disclaimer') }
        it { should have_selector('h3',
                                  text: 'SRDR Data Sharing Policy') }
    end # describe "visiting the 'Usage Policies' page" do

end # describe "StaticPages" do

