Feature: An editor specs a magazine
  As a current coeditor or editor,
  I want to specify when a magazine will accept submissions,
  and what it will be called,
  so that incoming submissions can be associated with it.

  Scenario: I set up a magazine
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And I am on the home page
    When I follow "Magazines"
    And I follow "Set up a new magazine"
    And I press "Save"
    Then I should be on the magazine's staff page

  Scenario: I edit a magazine
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And there is a magazine
    When I am on the magazines page
    And I click the edit link
    And I fill in the following:
      | Accepts submissions from  | 2009-02-20 |
      | Accepts submissions until | 2009-08-20 |
    And I press "Save"
    Then I should see "2009"
