# frozen_string_literal: true

require "cld3"

class LanguageService

  def detect_post_language(post)
    original_post = root_post(post)
    return if original_post.nil? || original_post.text.nil?

    result = cld3.find_language(original_post.text)
    return unless result

    post.language_id = result.language.to_s
    post.language_reliable = result.reliable?
  end

  def cld3
    @cld3 ||= CLD3::NNetLanguageIdentifier.new(0, 1000)
  end

  def self.language_for_public(default_language=I18n.locale.to_s)
    exclusive_languages = %w[en de fr es] # exclusive languages
    return [default_language] if exclusive_languages.include?(default_language)

    [default_language, "en"] # all other requested languages should return english plus the requested language
  end

  private

  def root_post(post)
    if post.type.eql?("Reshare")
      root_post = Post.find_by(guid: post.root_guid)
      return root_post unless root_post.nil?
    end
    post
  end
end
