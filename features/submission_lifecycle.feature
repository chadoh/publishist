Feature: A poet's work goes from draft to published/rejected
  As a poet, I want to write my poem on the website, submit it,
  and be aware of what is going on with it while waiting for it
  to either be published or rejected.

  Scenario: I submit when not signed in
    Given I am on the new submission page
    When I fill in the following:
      | Your Email Address | sm@tt.er |
      | Title | Each raindrop   |
      | Body  | started as dust |
    And I press "Submit!"
    Then "Each raindrop" should be submitted, not draft

  @webmember
  Scenario: I write a poem and then submit it later with edits
    Given I am on the new submission page
    When I fill in the following:
      | Title | Each raindrop   |
      | Body  | started as dust |
    And press "Save and Preview"
    Then I should be on my profile page
    And I should see "Drafts"

    When I follow "Edit" under "Each raindrop"
    And I press "Submit!"
    Then I should be on my profile page
    And I should not see "Drafts"

  @wip
  @webmember
  Scenario: I write a poem and then submit it later with edits
    Given I have drafted a poem called "Teh waistland"
    When I am on my profile page
    And I press "Submit"
    Then I should see "Submitted"
