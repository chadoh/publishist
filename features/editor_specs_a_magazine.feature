Feature: An editor specs a magazine
  As a current coeditor or editor,
  I want to specify when a magazine will accept submissions,
  and what it will be called,
  so that incoming submissions can be associated with it.

  @editor
  Scenario: I set up a magazine
    Given I am on the home page
    When I follow "Magazines"
    Then I should see "Set up a new magazine"

    When I follow "Set up a new magazine"
    And I press "Save"
    Then I should be on the magazines page

  @editor
  Scenario: I edit a magazine
    Given there is a magazine
    When I am on the magazines page
    And I follow "Edit"
    And I fill in the following:
      | Accepts submissions from  | 2009-02-20 |
      | Accepts submissions until | 2009-08-20 |
    And I press "Save"
    Then I should see "2009"
