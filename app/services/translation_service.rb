# frozen_string_literal: true

class TranslationService
  require "deepl"
  require "digest"

  def initialize(user=nil)
    @user = user
    DeepL.configure do |config|
      config.auth_key = AppConfig.deepl.auth_key
    end
  end

  def translate_for_post(post)
    translation = translate_text(post.text.to_s, @user.language)
    {
      translatedText:         translation.text,
      detectedSourceLanguage: translation.detected_source_language
    }
  end

  # Translate the translate Button
  # Fix eventhanding in UI
  # Show 'translation-button' only if enabled
  # In Admin-View: show statistics? -> New Task

  private

  def translate_text(text, target_language)
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
end
