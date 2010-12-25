Feature: an editor records attendance
  So that we know who is staff,
  and so that we can have some fun with silly questions,
  as the editor or coeditor
  I want to record attendance

  @editor
  Scenario: Recording attendance for someone who has an account
    Given there is a person named "Chad Ostrowski" with email address "chad@chadoh.com"
    And I am on the first meeting page
    When I fill in the following:
      | attendance_person | ;-) <chad@chadoh.com>   |
      | attendance_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see "Chad was there"
    And I should see a "Chad Ostrowski" link under "Attendance"

    When I press "Remove"
    Then I should see "Chad wasn't there, after all"

  @pending
  @editor
  Scenario: Creating an account for a new person by recording attendance correctly
    Given I am on the first meeting page
    When I fill in the following:
      | attendance_person | Cookie Monster <cookies@yomyom.com>   |
      | attendance_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see "Cookie was there"
    And I should see a "Cookie Monster" link under "Attendance"

  @editor
  Scenario: Recording attendance for someone without making them an account
    Given I am on the first meeting page
    When I fill in the following:
      | attendance_person | Cookie Monster |
      | attendance_answer | No more moon!  |
    And I press "Add"
    Then I should see "Cookie was there"
    And I should see "Cookie Monster" under "Attendance"
