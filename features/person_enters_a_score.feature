Feature: A person enters a score for a submission
  As someone who has attended a meeting,
  I want to enter a score for a submission,
  so that I can influence its chances of being published.

  Scenario: I view a meeting that I attended
    Given I'm in a position for the current magazine with the "views" ability
    And I attend the first meeting
    And there is a submission called "The King's Rager" scheduled for the first meeting
    When I go to the first meeting page
    Then I should be able to score "The King's Rager"

  Scenario: I view a meeting I did not attend
    Given I'm in a position for the current magazine with the "views" ability
    And I did not attend the first meeting
    And there is a submission called "The King's Rager" scheduled for the first meeting
    When I go to the first meeting page
    Then I should not be able to score "The King's Rager"
