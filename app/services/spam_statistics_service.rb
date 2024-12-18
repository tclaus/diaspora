# frozen_string_literal: true

class SpamStatisticsService
  def self.top_10_highest_spam_score_people
    Person.where("spam_score >= 0.5").order(spam_score: :desc).limit(10)
  end
end
