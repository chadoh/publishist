Feature: an editor records attendee
  So that we know who is staff,
  and so that we can have some fun with silly questions,
  as the editor or coeditor
  I want to record attendee

  @editor
  Scenario: Recording attendee for someone who has an account
    Given there is a person named "Chad Ostrowski" with email address "chad@chadoh.com"
    And I am on the first meeting page
    When I fill in the following:
      | attendee_person | ;-) <chad@chadoh.com>   |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see "Chad was there"
    And I should see a "Chad Ostrowski" link under "Attendee"

    When I press "Remove"
    Then I should see "Chad wasn't there, after all"

  @pending
  @editor
  Scenario: Creating an account for a new person by recording attendee correctly
    Given I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster <cookies@yomyom.com>   |
      | attendee_answer | This is not a laughing matter. |
    And I press "Add"
    Then I should see "Cookie was there"
    And I should see a "Cookie Monster" link under "Attendee"

  @editor
  Scenario: Recording attendee for someone without making them an account
    Given I am on the first meeting page
    When I fill in the following:
      | attendee_person | Cookie Monster |
      | attendee_answer | No more moon!  |
    And I press "Add"
    Then I should see "Cookie was there"
    And I should see "Cookie Monster" under "Attendee"
