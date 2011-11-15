Feature: people of various ranks submit something
  In order to have a chance at being published
  As an annonymous visitor, someone with an account, or the editor,
  I want to submit something!

  Scenario: The editor submits something
    Given I'm in a position for the current magazine with the "communicates" ability
    And no emails have been sent
    And I am on the new submission page
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

  Scenario: The editor submits for someone without making them an account
    Given I'm in a position for the current magazine with the "communicates" ability
    And I am on the new submission page
    When I fill in the following:
      | Title               | Old King Scole      |
      | Body                | Chewed Tobaccy      |
      | Author              |                     |
      | their name          | Someone             |
      | their email address | someone@example.com |
    And I press "Submit!"
    Then the submission should be submitted, not draft

  Scenario: The editor edits an anonymous submission
    Given I'm in a position for the current magazine with the "communicates" ability
    And no emails have been sent
    And there is a submission called "The King's Teeth"
    And I am on the first submission page
    When I follow "Edit"
    And I press "Save"
    Then I should be on the first submission page
    And I should receive no email

  Scenario: The editor edits a scored submission
    Given I'm in a position for the current magazine with the "communicates" ability
    And scores have been entered for a meeting
    And I am on the first submission page
    When I follow "Edit"
    And I press "Save"
    Then I should be on the first submission page

  Scenario: Some other signed-in person submits something
    Given I sign in
    And no emails have been sent
    And I am on the new submission page
    When I fill in the following:
      | Title | Merry Wives |
      | Body  | of Pirates  |
    And I press "Submit!"
    Then I should be on my profile page
    And "editor@problemchildmag.com" should receive an email

    When "editor@problemchildmag.com" opens the email
    Then they should see "example@example.com <admin@problemchildmag.com>" in the email "From" header
    And they should see "example@example.com" in the email "Reply-To" header

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

  Scenario: I submit under a psuedonym
    Given I sign in
    And I am on the new submission page
    When I fill in the following:
      | Title     | Merry Wives   |
      | Body      | of Pirates    |
      | Pseudonym | Jorgie Orwell |
    And I press "Submit!"
    Then I should see "Jorgie Orwell"
