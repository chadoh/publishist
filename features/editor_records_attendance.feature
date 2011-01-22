Feature: an editor records attendee
  So that we know who is staff,
  and so that we can have some fun with silly questions,
  as the editor or coeditor
  I want to record attendee

  @editor
  Scenario: Recording attendee for someone who has an account
    Given there is a person named "Peas Porridge Cold" with email address "chad@chadoh.com"
    And I am on the first meeting page
    When I fill in the following:
      | attendee_person | ;-), chad@chadoh.com           |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see a "Peas Cold" link under "Attendance"

    When I press "Remove"
    Then I should not see "Peas Cold"

  @pending
  @editor
  Scenario: Creating an account for a new person by recording attendee correctly
    Given I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster, cookies@yomyom.com   |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see a "Cookie Monster" link under "Attendance"

  @editor
  Scenario: Recording attendee for someone without making them an account
    Given I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster |
      | attendee_answer | No more moon!  |
    And I press "Add"
    Then I should see "Cookie Monster" under "Attendance"

  @editor
  Scenario: I edit an attendance record with javascript turned off
    Given someone named "O. J. Simpson" attended the first meeting
    And I am on the first meeting page
    When I follow "Edit"
    And I fill in the following:
      | attendee_person | Cookie Monster |
      | attendee_answer | No more moon!  |
    And I press "Update Attendee"
    Then I should see "Cookie Monster"
    And I should not see "O. J. Simpson"

  @wip
  @editor @javascript
  Scenario: I edit an attendance record with javascript turned on
    Given someone named "O. J. Simpson" attended the first meeting
    And I am on the first meeting page
    Then I should not see "Edit"

