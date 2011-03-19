Feature: You can't view the winners before it's time! (Or if you're not an editor…)
  Since viewing the highest-scored submissions will show the authors and imply the scores,
  and we want to keep the editors honest,
  editors should only be able to view the scores once a magazine's submission-timeframe is over.
  And no one else should be able to view them at all.

  @editor
  Scenario: The magazine hasn't stopped accepting submissions
    Given a magazine's timeframe is *nearly* over
    When I am on the magazines page
    Then I should not see "highest-scored"

  @webmember
  Scenario: The magazine has stopped accepting submissions
    Given a magazine's timeframe is freshly over
    When I am on the magazines page
    Then I should not see "highest-scored"
