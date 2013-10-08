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
    And the editor should receive an email

    When the editor opens the email
    Then they should get an email from '"example@example.com" <donotreply@publishist.com>'
    And they should see "example@example.com" in the email "Reply-To" header

    When I follow "Edit"
    And I press "Save"
    Then I should be on my profile page
    And "editor@problemchildmag.com" should receive no email

  Scenario: Someone with an account submits something while not signed in
    Given the following user exists:
      | name         | email             |
      | Roger Rabbit | roger@example.com |
    And I am on the new submission page
    When I fill in the following:
      | Your Name          | Pickles           |
      | Your Email Address | roger@example.com |
      | Title              | Merry Wives       |
      | Body               | of Pirates        |
    And I press "Submit!"
    Then "roger@example.com" should receive an email with subject "Someone \(hopefully you!\) submitted to ... for you!"

  Scenario: A bot fills out the honypot fields
    Given I am on the new submission page
    When I fill in the following:
      | Title                           | Jackson, a favorite       |
      | Body                            | of both Johnny and Sufjan |
      | Your Name                       | This Person               |
      | Your Email Address              | example@example.com       |
      | preference (please leave blank) | I'm so a bot              |
    And I press "Submit!"
    Then I should be on the home page
    And there should be no new submission

  Scenario: An anonymous visitor submits something & thus signs up
    Given I am on the new submission page
    When I fill in the following:
      | Title                           | Jackson, a favorite       |
      | Body                            | of both Johnny and Sufjan |
      | Your Name                       | This Person               |
      | Your Email Address              | example@example.com       |
    And I press "Submit!"
    Then I should be on the home page
    And I should receive an email with subject "You're nearly signed up!"
    And I should receive an email with subject "Someone \(hopefully you!\) submitted to ... for you!"
    And the editor should receive an email

    When the editor opens the email
    Then they should see "This Person <donotreply@publishist.com>" in the email "From" header
    And they should see "example@example.com" in the email "Reply-To" header

  Scenario: I submit under a psuedonym linked to my profile
    Given I sign in
    And I am on the new submission page
    When I fill in the following:
      | Title     | Merry Wives   |
      | Body      | of Pirates    |
      | Pseudonym | Jorgie Orwell |
    And I press "Submit!"
    Then I should be on my profile page
    Then I should see "Jorgie Orwell"

    When I follow "Merry Wives"
    Then I should see that "Jorgie Orwell" is a link

  Scenario: I submit under a psuedonym that is not linked to my profile
    Given I sign in
    And I am on the new submission page
    When I fill in the following:
      | Title     | Merry Wives   |
      | Body      | of Pirates    |
      | Pseudonym | Jorgie Orwell |
    And I uncheck "Link"
    And I press "Submit!"
    Then I should see "Merry Wives"

    When I follow "Merry Wives"
    Then I should see that "Jorgie Orwell" is not a link

  Scenario: Someone has work published under an unlinked pseudonym
    Given "Candace" has a published poem called "Wunderdog" under an unlinked pseudonym
    When I am on Candace's profile page
    Then I should not see "Wunderdog"
