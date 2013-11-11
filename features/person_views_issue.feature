Feature: People view issues of a publication

  Scenario: An anonymous visitor tries to view an unpublished issue
    Given a issue that has been 'published' but has not yet had the notification sent out to everyone
    When I visit the first issue page
    Then I should be on the home page
    And I should see "That hasn't been published yet, check back soon!"

    Given that the issue has its notification sent out
    When I visit the first issue page
    Then I should see "Staff ToC"
