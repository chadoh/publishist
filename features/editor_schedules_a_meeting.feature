Feature: Editor schedules a meetings
  So that any signed-in-user can browse meetings
  As the editor or coeditor
  I want to create a meeting

  @editor
  Scenario: Editor creates a meeting from the meetings index page
    Given I am on the meetings page
    When I follow "Schedule a new meeting"
    And I fill in the following:
      | When     | 2010-10-27 07:30 PM |
      | Question | Does he love you?   |
    And I press "Create Meeting"
    Then I should see "Does he love you?"

  @coeditor
  Scenario: Coeditor creates a meeting
    Given I am on the new meeting page
    When I fill in the following:
      | When     | 2010-10-27 07:30 PM |
      | Question | Does he love you?   |
    And I press "Create Meeting"
    And I am on the magazines page
    Then I should see "Does he love you?"

  @editor
  Scenario: Editor changes a meeting's question
    Given there is a meeting scheduled
    And I am on the meetings page
    When I follow "⚙"
    And I fill in "Question" with "What is the energy of your color?"
    And I press "Update Meeting"
    Then I should see "What is the energy of your color?"

  @webmember
  Scenario: Non-editors shouldn't have the link to schedule meetings
    Given I am on the meetings page
    Then I should not see "Schedule a new meeting"
