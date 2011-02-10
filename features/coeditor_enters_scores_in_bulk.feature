Feature: The coeditor enters scores in bulk
  As the coeditor,
  I want to bulk enter scores for attendees who didn't bring an internet device,
  so that their scores will count for something.

  @coeditor
  Scenario: The coeditor enters scores
    Given I and 2 more people attend the first meeting
    And there is a submission called "The Wasteland" scheduled for the first meeting
    When I go to the first meeting page
    And I score "The Wasteland"
    And I follow "Enter scores for everyone"
    Then I should see 2 score fields

  @coeditor
  Scenario: The coeditor checks scores
    Given scores have been entered for a meeting
    When I am on the submissions page
    Then I should see "Score:"
