Feature: People check out a meeting
  Meetings happen.
  Folks want to view them.
  Whether signed in or not.

  Scenario: I am not signed in. And I visit a meeting.
    Given I am on the first meeting page
    Then I should see "Problem Child"
