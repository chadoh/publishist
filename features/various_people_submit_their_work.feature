Feature: people of various ranks submit something
  In order to have a chance at being published
  As an annonymous visitor, someone with an account, or the editor,
  I want to submit something!

  @editor
  Scenario: The editor submits something
    Given I am on the new submission page
    When I fill in the following:
      | Title | Old King Scole |
      | Body  | Chewed Tobaccy |
    And I press "Preview"
    Then I should be on my profile page

    When I follow "Edit"
    And press "Submit!"
    Then I should be on the submissions page

    When I follow "Edit"
    Then I should not see "Submit!"

  @editor
  Scenario: The editor edits an anonymous submission
    Given there is a submission called "The King's Teeth"
    When I am on the first submission page
    And I follow "Edit"
    And I press "Save"
    Then I should be on the submissions page

  @editor
  Scenario: The editor edits a scored submission
    Given scores have been entered for a meeting
    And I am on the first submission page
    When I follow "Edit"
    And I press "Save"
    Then I should be on the submissions page

  @webmember
  Scenario: Some other signed-in person submits something
    Given I am on the new submission page
    When I fill in the following:
      | Title | Merry Wives |
      | Body  | of Pilates  |
    And I press "Submit!"
    Then I should be on my profile page

    When I follow "Edit"
    And I press "Save"
    Then I should be on my profile page

  Scenario: An anonymous visitor submits something
    Given I am on the new submission page
    When I fill in the following:
      | Title              | Jackson, a favorite       |
      | Body               | of both Johnny and Sufjan |
      | Your Name          | I'll never tell!          |
      | Your Email Address | someone@cool.com          |
    And I press "Submit!"
    Then I should be on the home page
