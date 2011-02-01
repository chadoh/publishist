Feature: A poet's work goes from draft to published/rejected
  As a poet, I want to write my poem on the website, submit it,
  and be aware of what is going on with it while waiting for it
  to either be published or rejected.

  @wip
  @webmember
  Scenario: I write a poem and then submit it later
    Given I am on the new submission page
    When I fill in the following:
      | Title | Each raindrop   |
      | Body  | started as dust |
    And press "Save"
    Then I should be on my profile page
    And I should see "Drafts"

    When I follow "Edit" under "Each raindrop"
    And I check "Submit"
    And I press "Save"
    Then I should be on my profile page
    And I should not see "Drafts"
