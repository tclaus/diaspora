# frozen_string_literal: true

class TranslationService
  require "deepl"
  require "digest"

  def initialize
    if AppConfig.deepl.enable && AppConfig.deepl.auth_key.present?
      DeepL.configure do |config|
        config.auth_key = AppConfig.deepl.auth_key
      end
    end
  end

  def translate_for_post(post)
    translation = translate_text(post.text.to_s)
    {
      translatedText:         translation.text,
      detectedSourceLanguage: translation.detected_source_language
    }
  end

  def enabled?
    return false unless AppConfig.deepl.enable && AppConfig.deepl.auth_key.present?
    return false if Rails.env.test?
    enabled_for_locale?
  end

  private

  def enabled_for_locale?
    local_language = I18n.locale.to_s.split("_").first.downcase
    supported_languages.any? {|supported_language| supported_language.code.downcase.eql?(local_language) }
  end

  def translate_text(text)
    target_language = I18n.locale.to_s.split("_").first
    hashed_text = Digest::SHA256.hexdigest(text)
    cache_key = "translatedPost/#{target_language}/#{hashed_text}"
    Rails.cache.fetch(cache_key) do
      DeepL.translate text, nil, target_language
    end
  rescue DeepL::Exceptions::Error
    I18n.t("translation.authkey_not_provided")
  rescue DeepL::Exceptions::RequestError
    I18n.t("translation.translation.error")
  end

  def supported_languages
    @supported_languages ||= DeepL.languages
  end

end
