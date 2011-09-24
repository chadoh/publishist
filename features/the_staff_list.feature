Feature: the staff list shows staff for a magazine and allows the editor to specify them
  As an editor,
  I want to specify who held various roles for a magazine.
  As an interested patron,
  I want to see who played a part.

  @editor
  Scenario: I set up a staff list
    Given a magazine has been published and I am viewing its cover
    When I follow "Staff"
    And I follow "Add a new position"
    And I fill in "Name" with "Editor"
    And I press "Save"
    Then I should see "Person" under "Editor"

    When I fill in "Person" with my email address
    And I press "Save"
    Then I should see my name under "Editor"

    Given there is a person named "Valencia Harding" with email address "val@hard.ing"
    When I follow "+"
    And I fill in "Person" with "val@hard.ing"
    And I press "Save"
    Then I should see "Valencia Harding" under "Editor"

    When I press "X"
    Then I should not see my name under "Editor"

    When I follow "⚙"
    And I fill in "Name" with "Coeditor"
    And I press "Save"
    Then I should see "Coeditor"

    When I press "×"
    Then I should not see "Coeditor"

  @editor
  Scenario: I set up a staff list for an unpublished magazine
    Given there is a magazine
    And I am on the magazines page
    Then I should see "Staff list"

    When I follow "Staff list"
    Then I should see "Add a new position"
    And I should see "Staff for the next magazine"
