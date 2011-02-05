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
    And I press "Submit!"
    Then I should be on my profile page

  @webmember
  Scenario: Some other signed-in person submits something
    Given I am on the new submission page
    When I fill in the following:
      | Title | Merry Wives |
      | Body  | of Pilates  |
    And I press "Submit!"
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
