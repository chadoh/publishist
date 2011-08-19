Feature: an editor views the winners for a magazine and publish the magazine
  In order to organize a magazine's submissions onto some physical pages
  And in order to determine what the highest-scored submissions are
  I would like to see all the winners.

  Background: a semester has passed
    Given a magazine's timeframe is freshly over
    And 10 submissions have been scored 1-10

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

  @editor
  Scenario: I publish the magazine and send the notification
    Given I am on the magazines page
    And I follow "View the highest-scored submissions"
    And no emails have been sent
    When I press "Publish checked submissions"
    And I press "Let everyone who submitted know"
    Then each author should receive an email
    And I should be on the magazine's cover page

    When I am on the magazines page
    Then I should see a link to the magazine
