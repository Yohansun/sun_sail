# -*- encoding : utf-8 -*-

Given /^exists user records$/ do
  FactoryGirl.create(:user, username: 'user', password: '123456')
end

Given /^I go to the login page$/ do
  visit new_user_session_path
end

Given /^I fill the login form with correct data$/ do
  fill_in 'user_email', with: 'user'
  fill_in 'user_password', with: '123456'
end

When /^I submit the login form$/ do
  click_button '登录'
end

Given /^I fill the login form with wrong data$/ do
  fill_in 'user_email', with: 'unknown'
  fill_in 'user_password', with: 'wrongpassword'
end

Then /^I should be on the login page$/ do
  page.should have_css(".centerDashboard")
  page.should have_content("登录")
  page.should_not have_content("注销")
end

Then /^I should be on the dashboard page$/ do
  page.should have_css(".centerDashboard")
  page.should have_content("注销")
end