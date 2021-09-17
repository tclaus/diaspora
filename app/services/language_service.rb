# frozen_string_literal: true

require "cld3"

class LanguageService
  def initialize(user=nil)
    @user = user
  end

  def detect_post_language(post)
    original_post = root_post(post)
    return if original_post.nil?

    result = cld3.find_language(original_post.text.to_s) if original_post.text.present?
    result = language_by_heuristic(post) if result.nil?
    return unless result

    post.language_id = result.language.to_s
    post.language_reliable = result.reliable?
  end

  def language_for_public
    return default_language if @user.nil?

    user_defined_language
  end

  private

  def user_defined_language
    user_languages = @user.stream_languages.pluck(:language_id)
    return user_languages if user_languages.present?

    default_language
  end

  def default_language
    default_language = I18n.locale.to_s
    exclusive_languages = %w[en de fr es ru] # exclusive languages
    return [default_language] if exclusive_languages.include?(default_language)

    [default_language, "en"] # all other requested languages should return english plus the requested language
  end

  def root_post(post)
    if post.type.eql?("Reshare")
      root_post = Post.find_by(guid: post.root_guid)
      return root_post unless root_post.nil?
    end
    post
  end

  def cld3
    @cld3 ||= CLD3::NNetLanguageIdentifier.new(0, 1000)
  end
end
