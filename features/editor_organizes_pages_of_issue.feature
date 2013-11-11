Feature: An editor organizes submissions onto pages of a issue
  A issue has been published!
  As an editor,
  I want to arrange it the same way on the web as it is when printed
  because _flow matters_.

  Background: We've published a issue
    Given there is a submission called "Everyone Dies, Anyway"
    And a issue nicknamed "Fruit Blots" has been published
    And I'm in a position for the "Fruit Blots" issue with the "orchestrates" ability
    And I am on the "Fruit Blots" issue page

  Scenario: I see that the vanilla published issue has sensible defaults
    Then I should see "Cover Notes Staff ToC 1" for the page numbers
    And I should see "Fruit Blots"
    And I should see "Cover Art"

  Scenario: I can add pages to the issue
    When I press "+"
    Then I should see "Cover Notes Staff ToC 1 2" for the page numbers

  Scenario: I can remove a page from the issue
    When I click the remove link
    Then I should see "Notes Staff ToC 0" for the page numbers

  Scenario: I can unpublish submissions
    Given I also have the "communicates" ability for the "Fruit Blots" issue
    When I follow "1"
    Then I should see "Everyone Dies, Anyway"

    When I press the unpublish button
    Then "Everyone Dies, Anyway" should be rejected
    And it should not be on a page
    And I should be on page 1 of the "Fruit Blots" issue

  @pending
  @javascript
  Scenario: I can rename pages
    When I'm on page "1"
    And I click on the page title ("1"), type "Last", and hit Return
    And I refresh the page
    Then I should see "Last"

  @pending
  @javascript
  Scenario: I can drag submissions onto other pages
    When I follow "1"
    And I press "+"
    And I drag "Everyone Dies, Anyway" to "2"
    Then I should be on page 1
    And I should not see "Everyone Dies, Anyway"
