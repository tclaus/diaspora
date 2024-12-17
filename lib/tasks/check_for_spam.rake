# frozen_string_literal: true

namespace :diaspora do
  desc "Checks and qualifies posts for spam"
  task detect_spam_on_posts: :environment do
    check_for_spam = Workers::CheckForSpam.new
    Post.where(spam: nil).find_in_batches do |posts|
      posts.each do |post|
        check_for_spam.check_for_spam(post)
      end
    end
  end

  task detect_spam_on_comments: :environment do
    check_for_spam = Workers::CheckForSpam.new
    Comment.where(spam: nil).find_in_batches do |comments|
      comments.each do |comment|
        check_for_spam.check_for_spam(comment)
      end
    end
  end
end
