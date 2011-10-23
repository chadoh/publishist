Feature: a person signs up for the website
  I want to view meetings
  and vote on shit.
  I need an account.

  Scenario: I sign up on the site
    Given I am on the sign up page
    When I fill in the following:
      | Name  | Ghengis Khan        |
      | Email | example@example.com |
    And I fail the CAPTCHA
    And I press "Sign Up!"
    Then I should see "You might not be a human."
    And all my information should still be filled out in the form

    When I pass the CAPTCHA
    And I press "Sign Up!"
    Then I should see "Ok! Now go check your email to finish signing up."
    And I should receive an email with subject "You're nearly signed up for Problem Child!"

    When I open the email
    And I follow "set your password" in the email
    Then I should see "Almost there"

    When I fill in the following:
      | Password              | secret |
      | Password confirmation | secret |
    And I press "Get going"
    Then I should see "You're legit now."
    And I should see "Ghengis Khan"
    And I should be on the home page

  Scenario: I edit my profile
    Given I sign in
    And I am on my profile page
    When I follow "Edit account details"
    Then I should see "Edit Account"

    When I fill in "Name" with "Ghengis"
    And I fill in "Current password" with "secret"
    And press "Save Changes"
    Then I should see "Ghengis" 2 times
