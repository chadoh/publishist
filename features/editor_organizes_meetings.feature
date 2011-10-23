Feature: an editor organizes meetings into various magazines
  As an editor,
  when I create meetings and the pcmag site puts them in the wrong magazine,
  I want to be able to reorganize them.

  Scenario: an orphaned meeting
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And there is a meeting with the question "Orly?" that is somehow orphaned
    When I am on the meetings page
    Then I should see "Orly?"
