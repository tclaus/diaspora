# frozen_string_literal: true

require "test_helper"

class StatisticsServiceTest < ActiveSupport::TestCase
  test "should return top 10 highest spam score people with spam_score > 0.5" do
    # Setup: Create 15 people with varied spam_scores
    (1..15).each do |i|
      Person.create(spam_score: i * 0.1) # Spam scores: 0.1, 0.2, ..., 1.5
    end

    result = SpamStatisticsService.top_10_highest_spam_score_people

    # Assert: Check if the result contains only 10 records
    assert_equal 10, result.count

    # Assert: Check if all spam_score values in result are > 0.5
    assert result.all? {|person| person.spam_score > 0.5 }, "All spam_scores should be greater than 0.5"
  end

  test "should return an empty relation if no Person records match the criteria" do
    # Setup: Ensure no matching records exist
    Person.delete_all
    Person.create(spam_score: 0.4)

    result = SpamStatisticsService.top_10_highest_spam_score_people

    # Assert: Check if the result is an ActiveRecord::Relation
    assert_instance_of ActiveRecord::Relation, result

    # Assert: Check if the result is empty
    assert_empty result
  end
end
