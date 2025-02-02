# frozen_string_literal: true

class SpamStatisticsService
  def self.highest_spam_score_people
    Person.where(spam_score: 0.6..)
          .where.not(owner_id: nil)
          .where(closed_account: false)
          .order(spam_score: :desc).limit(20)
  end
end
