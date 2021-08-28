@javascript
Feature: reporting of posts and comments

  Background:
    Given a user with username "bob"
    And a moderator with email "alice@alice.alice"
    And "bob@bob.bob" has a public post with text "I'm a post by Bob"
    And the terms of use are enabled

  Scenario: User can report a post, but cannot report it twice
    Given I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".stream-element"
    And I click to report the post
    Then I should see the report modal
    And I should see "You should only report posts or comments which violates"
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    Then I should see a success flash message containing "The report has successfully been created"
    When I hover over the ".stream-element"
    And I click to report the post
    And I fill in "report-reason-field" with "That's my reason2"
    And I submit the form
    Then I should see an error flash message containing "The report already exists"
    When I go to the report page
    Then I should see a report by "alice@alice.alice" with reason "That's my reason" on post "I'm a post by Bob"
    And "alice@alice.alice" should have received an email with subject "A new post was marked as offensive"

  Scenario: User can report a comment, but cannot report it twice
    Given "bob@bob.bob" has commented "Bob comment" on "I'm a post by Bob"
    And I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".comment"
    And I click to report the comment
    Then I should see the report modal
    When I fill in "report-reason-field" with "That's my reason"
    And I submit the form
    Then I should see a success flash message containing "The report has successfully been created"
    When I hover over the ".comment"
    And I click to report the comment
    And I fill in "report-reason-field" with "That's my reason2"
    And I submit the form
    Then I should see an error flash message containing "The report already exists"
    When I go to the report page
    Then I should see a report by "alice@alice.alice" with reason "That's my reason" on comment "Bob comment"
    And "alice@alice.alice" should have received an email with subject "A new comment was marked as offensive"

    Scenario: A checked report appears in the Reviewed section as reviewed
      Given I sign in as "alice@alice.alice"
      And I am on the public stream page
      When I hover over the ".stream-element"
      And I click to report the post
      Then I should see the report modal
      When I fill in "report-reason-field" with "That's my reason"
      And I submit the form
      When I go to the report page
      And I mark report as reviewed
      When I open the reviewed tab on the report page
      Then I should see the reviewed report with decision No Action

  Scenario: A deleted report content appears in the Reviewed section as deleted
    Given I sign in as "alice@alice.alice"
    And I am on the public stream page
    When I hover over the ".stream-element"
    And I click to report the post
    Then I should see the report modal
    When I fill in "report-reason-field" with "That should no be here"
    And I submit the form
    When I go to the report page
    And I mark report as deleted
    When I open the reviewed tab on the report page
    Then I should see the reviewed report with decision Deleted

    Scenario: A reviewed report can be deleted afterwards
      Given I sign in as "alice@alice.alice"
      And I am on the public stream page
      When I hover over the ".stream-element"
      And I click to report the post
      Then I should see the report modal
      When I fill in "report-reason-field" with "That's my reason"
      And I submit the form
      When I go to the report page
      And I mark report as reviewed
      When I open the reviewed tab on the report page
      And I confirm the alert after I delete the reviewed report
      When I open the reviewed tab on the report page
      Then I should see the reviewed report with decision Deleted
