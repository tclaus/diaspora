namespace :diaspora do
  desc "Detects languages uses in posts"
  task detect_languages: :environment do
    language_service = LanguageService.new
    Post.where(language_id: nil).find_in_batches do |posts|
      posts.each do |post|
        language_service.detect_post_language(post)
        post.save(touch: false)
      end
    end
  end

end
