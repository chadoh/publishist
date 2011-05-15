Feature: an editor views the winners for a magazine
  In order to organize a magazine's submissions onto some physical pages
  And in order to determine what the highest-scored submissions are
  I would like to see all the winners.

  Background: a semester has passed
    Given a magazine's timeframe is freshly over
    And 10 meetings have occured in it
    And 10 submissions have been reviewed at these meetings
    And 10 people have attended each of these meetings
    And submissions at meeting 1 have all been scored 1, scored 2 at meeting 2, etc

  @editor
  Scenario: I view the winners
    Given I am on the magazines page
    When I follow "View the highest-scored submissions"
    Then I should see "7" in the "highest" field
    And I should see 7 submissions

    When I fill in "highest" with "5"
    And  I press "→"
    Then I should see 5 submissions

    When I fill in "above" with "6"
    And  I press "→"
    Then I should see 4 submissions

    Given no emails have been sent
    When I press "Publish checked submissions"
    Then each author should receive an email
    And I should be on the first magazine page
