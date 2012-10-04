Feature: User login system
  Background:
    Given exists user records

  Scenario: User logins with correct username and password
    Given I go to the login page
    And I fill the login form with correct data
    When I submit the login form
    Then I should be on the dashboard page

  Scenario: User logins with wrong username and password
    Given I go to the login page
    And I fill the login form with wrong data
    When I submit the login form
    Then I should be on the login page