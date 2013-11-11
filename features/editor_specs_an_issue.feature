Feature: An editor specs a issue
  As a current coeditor or editor,
  I want to specify when a issue will accept submissions,
  and what it will be called,
  so that incoming submissions can be associated with it.

  Scenario: I set up a issue
    Given I'm in a position for the current issue with the "orchestrates" ability
    And I am on the home page
    When I follow "Issues"
    And I follow "Set up a new issue"
    And I press "Save"
    Then I should be on the issue's staff page

  Scenario: I edit a issue
    Given I'm in a position for the current issue with the "orchestrates" ability
    When I am on the issues page
    And I click the edit link
    And I fill in the following:
      | Accepts submissions from  | 2009-02-20 |
      | Accepts submissions until | 2009-08-20 |
    And I press "Save"
    Then I should see "2009"
