Feature: People check out a meeting
  Meetings happen.
  Folks want to view them.
  But they gots to be signed in.

  Scenario: I am not signed in. And I visit a meeting.
    Given I'm in a position for the current magazine with the "views" ability
    And I am signed out
    And I am on the first meeting page
    Then I should see "sign in"

    When I fill in the following:
      | Email    | example@example.com |
      | Password | secret                    |
    And I press "Sign in"
    Then I should be on the first meeting page
