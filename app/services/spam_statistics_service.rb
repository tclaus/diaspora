# frozen_string_literal: true

class SpamStatisticsService
  def self.top_10_highest_spam_score_people
    Person.where("spam_score >= 0.6").order(spam_score: :desc).limit(20)
  end
end
