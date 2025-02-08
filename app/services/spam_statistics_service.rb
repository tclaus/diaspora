# frozen_string_literal: true

class SpamStatisticsService
  def self.highest_spam_score_people

    Person.left_joins(:posts, :comments) # Use left_joins to calculate counts properly
          .where(spam_score: 0.6..)
          .where.not(owner_id: nil)
          .where(closed_account: false)
          .select('people.*, COUNT(posts.id) AS posts_count, COUNT(comments.id) AS comments_count')
          .group('people.id')
          .order('posts_count DESC, comments_count DESC')
          .limit(20)
  end
end
