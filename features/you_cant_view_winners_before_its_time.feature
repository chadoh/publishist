Feature: You can't view the winners before it's time! (Or if you're not an editor…)
  Since viewing the highest-scored submissions will show the authors and imply the scores,
  and we want to keep the editors honest,
  editors should only be able to view the scores once a magazine's submission-timeframe is over.
  And no one else should be able to view them at all.

  Scenario: The magazine hasn't stopped accepting submissions
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And a magazine's timeframe is *nearly* over
    When I am on the magazines page
    Then I should not see "highest-scored"

  Scenario: The magazine has stopped accepting submissions, but no scores have been entered for the submissions
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And the magazine's timeframe is freshly over
    And 1 meeting has occured in it
    And 1 submission has been reviewed at this meeting
    When I am on the magazines page
    And I follow "highest-scored"
    Then I should see "never entered any scores"

  Scenario: The magazine has stopped accepting submissions
    Given I sign in
    And a magazine's timeframe is freshly over
    When I am on the magazines page
    Then I should not see "highest-scored"
