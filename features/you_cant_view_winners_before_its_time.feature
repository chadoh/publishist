Feature: You can't view the winners before it's time! (Or if you're not an editor…)
  Since viewing the highest-scored submissions will show the authors and imply the scores,
  and we want to keep the editors honest,
  editors should only be able to view the scores once a issue's submission-timeframe is over.
  And no one else should be able to view them at all.

  Scenario: The issue hasn't stopped accepting submissions
    Given I'm in a position for the current issue with the "orchestrates" ability
    And a issue's timeframe is *nearly* over
    When I am on the issues page
    Then I should not see "highest-scored"

  Scenario: The issue has stopped accepting submissions, but no scores have been entered for the submissions
    Given I'm in a position for the current issue with the "orchestrates" ability
    And the issue's timeframe is freshly over
    And 1 meeting has occured in it
    And 1 submission has been reviewed at this meeting
    When I am on the issues page
    And I follow "highest-scored"
    Then I should see "never entered any scores"

  Scenario: The issue has stopped accepting submissions
    Given I sign in
    And a issue's timeframe is freshly over
    When I am on the issues page
    Then I should not see "highest-scored"
