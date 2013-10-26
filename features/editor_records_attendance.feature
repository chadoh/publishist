Feature: an editor records attendee
  So that we know who is staff,
  and so that we can have some fun with silly questions,
  as the editor or coeditor
  I want to record attendee

  Scenario: Recording attendee for someone who has an account
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And there is a person named "Peas Porridge Cold" with email address "chad@chadoh.com"
    And I am on the first meeting page
    When I fill in the following:
      | attendee_person | ;-), chad@chadoh.com           |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see a "Peas Cold" link under "Attendance"

    When I click the remove link
    Then I should not see "Peas Cold"

  Scenario: Creating an account for a new person by recording attendee correctly
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster, cookies@yomyom.com   |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see a "Cookie Monster" link under "Attendance"

  Scenario: Recording attendee for someone without making them an account
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster |
      | attendee_answer | No more moon!  |
    And I press "Add"
    Then I should see "Cookie Monster" under "Attendance"

  Scenario: I edit an attendance record with javascript turned off
    Given I'm in a position for the current magazine with the "orchestrates" ability
    And someone named "O. J. Simpson" attended the first meeting
    And I am on the first meeting page
    When I click the edit link
    And I fill in the following:
      | attendee_person | Cookie Monster |
      | attendee_answer | No more moon!  |
    And I press "Update Attendee"
    Then I should see "Cookie Monster"
    And I should not see "O. J. Simpson"
