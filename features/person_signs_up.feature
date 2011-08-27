Feature: a person signs up for the website
  I want to view meetings
  and vote on shit.
  I need an account.

  Scenario: I sign up on the site
    Given I am on the sign up page
    When I fill in the following:
      | Email                 | ghengis.khan@example.com |
      | First name            | Ghengis                  |
      | Last name             | Khan                     |
      | Password              | secret                   |
      | Password confirmation | secret                   |
    And I fail the CAPTCHA
    And I press "Sign Up!"
    Then I should see "You might not be a human."
    And all my information should still be filled out in the form

    When I fill in the following:
      | Password confirmation | secret |
      | Password              | secret |
    And I pass the CAPTCHA
    And I press "Sign Up!"
    Then I should see "You have signed up successfully."
    And I should be on the home page

  @webmember
  Scenario: I edit my profile
    Given I am on my profile page
    When I follow "Edit account details"
    Then I should see "Edit Account"

    When I fill in "First name" with "Ghengis"
    And I fill in "Current password" with "secret"
    And press "Save Changes"
    Then I should see "Ghengis"
