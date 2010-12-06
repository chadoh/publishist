Feature: An editor promotes someone to a higher rank
  In order to specify that someone is staff, coeditor, or editor
  As a current editor or coeditor,
  I want to promote them

  @editor
  Scenario: Promoting someone through the ranks
    Given there is a person named "Daffy Duck" with email address "daffy@loony.com"
    And there is a person named "Cookie Monster" with email address "cookies@yomyom.com"
    And I am on the people page
    When I promote Daffy to staff
    Then I should see that Daffy is now staff
    And I should see "Daffy has been promoted!"

    When I promote Cookie Monster to staff
    Then I should see that Cookie Monster is now staff
    And I should see that Daffy is still staff
    And I should see "Cookie has been promoted!"

    When I promote Daffy to coeditor
    Then I should see that Daffy is now coeditor
    And I should see "Daffy has been promoted!"

    When I promote Cookie Monster to coeditor
    Then I should see that Cookie Monster is now coeditor
    And I should see that Daffy is not coeditor
    And I should see "Cookie has been promoted!"

    When I promote Daffy to editor
    Then I should see that Daffy is now editor
    And I should see "Daffy has been promoted!"
    #And I should see that I am not editor
    And I should not see "Promote"
