Feature: Editor schedules a meetings
  So that any signed-in-user can browse meetings
  As the editor or coeditor
  I want to create a meeting

  Scenario: Editor creates a meeting from the meetings index page
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And I am on the meetings page
    When I follow "Schedule a new meeting"
    And I fill in the following:
      | When     | 2010-10-27 07:30 PM |
      | Question | Does he love you?   |
    And I press "Create Meeting"
    Then I should see "Does he love you?"

  Scenario: Editor changes a meeting's question
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And there is a meeting scheduled
    And I am on the meetings page
    When I follow "⚙"
    And I fill in "Question" with "What is the energy of your color?"
    And I press "Update Meeting"
    Then I should see "What is the energy of your color?"

  Scenario: Non-editors shouldn't have the link to schedule meetings
    Given I sign in
    And I am on the meetings page
    Then I should not see "Schedule a new meeting"
