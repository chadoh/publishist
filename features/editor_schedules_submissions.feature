Feature: An editor organizes submissions into packlets
  In order to organize submissions for review at meetings
  As an editor or coeditor
  I want to drag and drop them into place from the submissions page

  @pending
  @javascript
  Scenario: Scheduling unscheduled submissions into two future meetings
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And there is a submission called "Lisa, the Cat"
    And there are several meetings
    And I am on the submissions page
    When I drag "Lisa, the Cat" to the first meeting
    Then I should not see "Lisa, the Cat" under "Unscheduled"
    And I should see "Lisa, the Cat" under the first meeting

    When I drag "Lisa, the Cat" to the second meeting
    Then I should see "Lisa, the Cat" under the first meeting
    And I should see "Lisa, the Cat" under the second meeting

    When I drag "Lisa, the Cat" from the second meeting to "Unscheduled"
    Then I should not see "Lisa, the Cat" under the second meeting
    And I should see "Lisa, the Cat" under the first meeting
    And I should not see "Lisa, the Cat" under "Unscheduled"

    When I drag "Lisa, the Cat" from the first meeting to "Unscheduled"
    Then I refresh the page
    Then I should see "Lisa, the Cat" under "Unscheduled"

  @pending
  @javascript
  Scenario: The editor sorts submissions within the packlet
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And the following submissions are scheduled for a meeting a week from now:
      | title             | body             |
      | A Hydrogen Baloon | Oh the humanatee |
      | Lunatics' Rant    | Stopstopstopstop |
    And I am on the first meeting page
    When I drag "Lunatics' Rant" on top
    Then "Lunatics' Rant" should be above "A Hydrogen Baloon"

    When I refresh the page
    Then "Lunatics' Rant" should be above "A Hydrogen Baloon"
