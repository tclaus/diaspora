# frozen_string_literal: true

module LanguageHelper
  include ApplicationHelper

  def available_language_options
    options = []
    AVAILABLE_LANGUAGES.each do |locale, language|
      options << [language, locale]
    end
    options.sort_by { |o| o[0] }
  end

  def selected_stream_languages(user)
    options = []
    AVAILABLE_LANGUAGES.each do |locale, language|
      options << [language, locale] if user.stream_languages.pluck(:language_id).include?(locale)
    end
    options.sort_by {|o| o[0] }
  end

  def available_stream_languages(user)
    options = []
    allowed_languages = language_ids
    AVAILABLE_LANGUAGES.each do |locale, language|
      if allowed_languages.include?(locale) && user.stream_languages.pluck(:language_id).exclude?(locale)
        options << [language, locale]
      end
    end
    options.sort_by {|o| o[0] }
  end

  def language_ids
    # language_distribution_in_posts
    ids = []
    language_distribution_in_posts.each do |pair|
      ids << pair["language_id"]
    end
    ids
  end

  def language_distribution_in_posts
    Rails.cache.fetch("post_language_distribution", expires_in: 1.day) do
      fetch_language_distribution_in_posts
    end
  end

  def fetch_language_distribution_in_posts
    sql = "select count(*), language_id from posts
           where public = true and language_id is not null
           group by language_id order by count(*) desc"
    ActiveRecord::Base.connection.exec_query sql
  end

  def get_javascript_strings_for(language, section)
    translations = I18n.t(section, locale: DEFAULT_LANGUAGE).dup
    translations.deep_merge!(I18n.t(section, locale: language)) if language != DEFAULT_LANGUAGE

    translations["pluralization_rule"] = I18n.t("i18n.plural.js_rule", locale: language)
    translations["pod_name"] = pod_name
    translations
  end

  def direction_for(string)
    return '' unless string.respond_to?(:cleaned_is_rtl?)
    string.cleaned_is_rtl? ? 'rtl' : 'ltr'
  end

  def rtl?
    @rtl ||= RTL_LANGUAGES.include?(I18n.locale.to_s)
  end
end
