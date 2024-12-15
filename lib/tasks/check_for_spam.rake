namespace :diaspora do
  desc "Checks and qualifies posts for spam"
  task detect_spam: :environment do
    Post.where(spam: nil).find_in_batches do |posts|
      posts.each do |post|
        check_for_spam = Workers::CheckForSpam.new
        check_for_spam.perform(post.class.name, post.guid)
      end
    end
  end
end
