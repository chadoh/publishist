Feature: An Editor Emeritus enters submissions for an old magazine
  As someone who once was editor
  I want to fill in the magazines that were published while I was there
  So that I and everyone else can access them quickly & easily online.

  @wip
  Scenario: I submit published works for an old magazine
    Given a very old magazine called "maps"
    And a current magazine called "produce prints"
    Given I'm in a position for the "maps" magazine with the "communicates" ability
    When I go to the submit page
    And I fill in the following:
      | Title     | Letters from Aching |
      | Body      | Dear Occupant: &c…  |
    And I select "the maps issue" from "Magazine"
    And I press "Submit!"
    Then "Letters from Aching" should be published
