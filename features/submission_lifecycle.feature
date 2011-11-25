Feature: A poet's work goes from draft to published/rejected
  As a poet, I want to write my poem on the website, submit it,
  and be aware of what is going on with it while waiting for it
  to either be published or rejected.

  Scenario: I write a poem and then submit it later with edits
    Given I sign in
    And I am on the new submission page
    When I fill in the following:
      | Title | Each raindrop   |
      | Body  | started as dust |
    And press "Preview"
    Then I should be on my profile page
    And I should see "Drafts"

    When I follow "Edit" under "Each raindrop"
    And I press "Submit!"
    Then I should be on my profile page
    And I should not see "Drafts"

  Scenario: I write a poem and then submit it later without edits
    Given I sign in
    And I have drafted a poem called "Teh waistland"
    When I am on my profile page
    And I press "Submit"
    Then I should see "Submitted"

  Scenario: A poem I write is scheduled for a meeting
    Given I sign in
    And I have submitted a poem called "Los Colores"
    And "Los Colores" is scheduled for a meeting a week from now
    When I am on my profile page
    Then I should see "Queued"
    And I should see "⚙" under "Los Colores"
    And I should see "Scheduled to be reviewed in"

    Given the "Los Colores" meeting is two hours away
    When I am on my profile page
    Then I should not see "Edit" under "Los Colores"
    And I should see "Reviewed" 2 times

  Scenario: A poem I write has been scored
    Given I sign in
    And I have submitted a poem called "Melki's a deck"
    And I have gone to the meeting and scored "Melki's a deck"
    When I am on my profile page
    Then I should see "Scored"
    And I should see "Score:" under "Melki's a deck"
