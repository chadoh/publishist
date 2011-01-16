Feature: An editor organizes submissions into packets
  In order to organize submissions for review at meetings
  As an editor or coeditor
  I want to drag and drop them into place from the submissions page

  @editor @javascript
  Scenario: Scheduling unscheduled submissions into two future meetings
    Given there are several submissions
    And there are several meetings
    And I am on the submissions page
    When I drag "Submission 1" to the first meeting
    Then I should not see "Submission 1" under "Unscheduled"
    And I should see "Submission 1" under the first meeting

    When I drag "Submission 1" to the second meeting
    Then I should see "Submission 1" under the first meeting
    And I should see "Submission 1" under the second meeting

    When I drag "Submission 1" from the first meeting to "Unscheduled"
    Then I should not see "Submission 1" under the first meeting
    And I should see "Submission 1" under the second meeting
    And I should not see "Submission 1" under "Unscheduled"

  @pending
  @editor @javascript
  Scenario: The editor sorts submissions within the packet
    Given the following submissions are scheduled for a meeting a week from now:
      | title             | body             | author_email       |
      | A Hydrogen Baloon | Oh the humanatee | cookies@yomyom.com |
      | Lunatics' Rant    | Stopstopstopstop | daffy@loony.com    |
    And I am on the first meeting page
    When I drag "Lunatics' Rant" on top
    And pending
    Then "Lunatics' Rant" should be above "A Hydrogen Baloon"

    When I refresh the page
    Then "Lunatics' Rant" should be above "A Hydrogen Baloon"
