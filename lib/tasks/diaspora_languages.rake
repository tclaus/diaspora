# frozen_string_literal: true

namespace :diaspora do
  desc "Detects languages uses in posts and comments"
  task detect_languages_in_posts: :environment do
    language_service = LanguageService.new
    Post.where(language_id: nil).find_in_batches do |posts|
      posts.each do |post|
        language_service.detect_post_language(post)
        post.save(touch: false)
      end
    end
  end

  task detect_languages_in_comments: :environment do
    language_service = LanguageService.new
    Comment.where(language_id: nil).find_in_batches do |comments|
      comments.each do |comment|
        language_service.detect_comment_language(comment)
        comment.save(touch: false)
      end
    end
  end
end
