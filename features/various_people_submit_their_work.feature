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
    Then I should be on my profile page
    And I should receive no email

    When I follow "Edit"
    Then I should not see "Submit!"

  @editor
  Scenario: The editor edits an anonymous submission
    Given there is a submission called "The King's Teeth"
    And I am on the first submission page
    When I follow "Edit"
    And I press "Save"
    Then I should be on the first submission page
    And I should receive no email

  @editor
  Scenario: The editor edits a scored submission
    Given scores have been entered for a meeting
    And I am on the first submission page
    When I follow "Edit"
    And I press "Save"
    Then I should be on the first submission page

  Scenario: Some other signed-in person submits something
    Given the following user exists:
      | name         | email             |
      | Roger Rabbit | roger@example.com |
    And I sign in as "roger@example.com/password"
    And I am on the new submission page
    When I fill in the following:
      | Title | Merry Wives |
      | Body  | of Pilates  |
    And I press "Submit!"
    Then I should be on my profile page
    When "editor@problemchildmag.com" opens the email
    Then they should see "Roger Rabbit <admin@problemchildmag.com>" in the email "From" header
    And they should see "roger@example.com" in the email "Reply-To" header

    When I follow "Edit"
    And I press "Save"
    Then I should be on my profile page
    And "editor@problemchildmag.com" should receive no email

  Scenario: An anonymous visitor submits something
    Given I am on the new submission page
    When I fill in the following:
      | Title              | Jackson, a favorite       |
      | Body               | of both Johnny and Sufjan |
      | Your Name          | I'll never tell!          |
      | Your Email Address | someone@cool.com          |
    And I fail the CAPTCHA
    And I press "Submit!"
    Then I should see "You might be a bot!"
    And my submission should still be filled in

    When I pass the CAPTCHA
    And I press "Submit!"
    Then I should be on the home page

    When "editor@problemchildmag.com" opens the email
    Then they should see "I'll never tell! <admin@problemchildmag.com>" in the email "From" header
    And they should see "someone@cool.com" in the email "Reply-To" header
