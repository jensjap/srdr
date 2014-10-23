include ApplicationHelper

def full_title(page_title)
    base_title = "SRDR - Systematic Review Data Repository"
    if page_title.empty?
        base_title
    else
        "#{base_title} | #{page_title}"
    end
end

def sign_in(user)
  visit login_path
  fill_in "Username", with: user.login
  fill_in "Password", with: user.password
  click_button "Log In"
  # Sign in when not using Capybara as well.
  #cookies[:remember_token] = user.remember_token
end
