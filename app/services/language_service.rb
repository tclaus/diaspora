# frozen_string_literal: true

require "cld3"

class LanguageService
  CLD = CLD3::NNetLanguageIdentifier.new(50, 780)

  def initialize(user=nil)
    @user = user
  end

  def detect_post_language(post)
    original_post = root_post(post)
    return if original_post.nil?

    result = cld3.find_language(original_post.text.to_s) if original_post.text.present?
    result = language_by_heuristic(post) if result.nil?
    return unless result
    if result.reliable?
      post.language_id = result.language.to_s.split("_").first
    end
  end

  def language_for_public
    return default_language if @user.nil?

    post.language_id = result.language.to_s
    post.language_reliable = result.reliable?
  end

  def language_for_public
    return default_language if @user.nil?

    user_defined_language
  end

  def self.language_for_public(default_language=I18n.locale.to_s)
    exclusive_languages = %w[en de fr es] # exclusive languages
  private

  def user_defined_language
    @user.stream_languages.pluck(:language_id)
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

  # If a post can not be get a used language directly, it look to the other posts from same user.
  def language_by_heuristic(post)
    reference = Post.where("author_id = posts.author_id and language_id is not null")
                    .group(:language_id)
                    .order(count_all: :desc)
                    .count
                    .first
    return if reference.nil? || reference.first.nil?

    post_language = PostLanguage.new
    post_language.language = reference.first
    post_language.reliable = true
    post_language
  end

  def remove_urls_from_text(text)
    pattern = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
    text.gsub(pattern, " ")
  end

  class PostLanguage
    attr_accessor :language, :reliable

    def reliable?
      reliable
    end
  end
end
