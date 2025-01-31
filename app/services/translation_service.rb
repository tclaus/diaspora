# frozen_string_literal: true

class TranslationService
  require "deepl"
  require "digest"

  def initialize
    return unless AppConfig.deepl.enable && AppConfig.deepl.auth_key.present?

    DeepL.configure do |config|
      config.auth_key = AppConfig.deepl.auth_key
    end
  end

  def translate_message(message)
    translation = translate_text(message)
    {
      translatedText:         translation[:text],
      detectedSourceLanguage: translation[:detected_source_language]
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
    begin
      supported_languages.any? {|supported_language| supported_language.code.downcase.eql?(local_language) }
    rescue StandardError
      false
    end
  end

  def translate_text(message)
    target_language = I18n.locale.to_s.split("_").first
    translated_text = TranslatedText.find_by(message_uid: message.guid, translated_language_id: target_language)

    unless translated_text.nil?
      increment_hits(translated_text)
      return {
        text:                     translated_text.translated_text,
        detected_source_language: translated_text.original_language_id
      }
    end

    query_translation_api(message, target_language)
  rescue DeepL::Exceptions::Error
    I18n.t("translation.authkey_not_provided")
  rescue DeepL::Exceptions::RequestError
    I18n.t("translation.translation.error")
  end

  def increment_hits(translated_text)
    translated_text.increment(:hits)
    translated_text.save
  end

  def query_translation_api(message, target_language)
    translated_text = DeepL.translate message.text, nil, target_language
    store_translation(translated_text, message, target_language)
    {
      text:                     translated_text.text,
      detected_source_language: translated_text.detected_source_language
    }
  end

  def store_translation(translated_text, message, target_language)
    hashed_text = Digest::SHA256.hexdigest(message.text)
    TranslatedText.create(message_uid:            message.guid,
                          hashed_original_text:   hashed_text,
                          original_language_id:   translated_text.detected_source_language,
                          translated_text:        translated_text.text,
                          translated_language_id: target_language)
  end

  def supported_languages
    @supported_languages ||= DeepL.languages
  end
end
