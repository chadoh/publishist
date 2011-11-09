Feature: An anonymous viewer checks out a magazine
  As some citizen of the internet,
  I want to see what Problem Child is all about.
  I want to browse a magazine it's published.

  Scenario: An anonymous visitor tries to view magazines
    Given a magazine that has been 'published' but has not yet had the notification sent out to everyone
    When I visit the first magazine page
    Then I should be on the home page
    And I should see "That hasn't been published yet, check back soon!"

    Given that the magazine has its notification sent out
    When I visit the first magazine page
    Then I should see "Staff ToC"
