Feature: An editor specs a magazine
  As a current coeditor or editor,
  I want to specify when a magazine will accept submissions,
  and what it will be called,
  so that incoming submissions can be associated with it.

  @wip
  @editor
  Scenario: I set up a magazine
    Given I am on the home page
    When I follow "Magazines"
    Then I should see "Set up a new magazine"

    When I follow "Set up a new magazine"
    And I press "Save"
    Then I be on the first magazine page
    And the first magazine should not have a title
    And the first magazine should have an abbreviated name "next"
    And the first magazine should accept submissions from today until six months from now
