# frozen_string_literal: true

class TranslationService
  require "deepl"
  require "digest"

<<<<<<< HEAD
  def initialize(user=nil)
    @user = user
=======
  def initialize
>>>>>>> post_translations
    DeepL.configure do |config|
      config.auth_key = AppConfig.deepl.auth_key
    end
  end

  def translate_for_post(post)
    translation = translate_text(post.text.to_s)
    {
      translatedText:         translation.text,
      detectedSourceLanguage: translation.detected_source_language
    }
  end

  # rubocop:disable Metrics/MethodLength

  def self.enabled?
    false unless AppConfig.deepl.enable
    supported_languages = %w[bg
                             cs
                             da
                             de
                             el
                             en
                             es
                             hu
                             it
                             lt
                             lv
                             pl
                             pt
                             ro
                             ru
                             sk
                             sl
                             sv
                             zh]

    supported_languages.include? I18n.locale.to_s.split("_").first
  end

  # rubocop:enable Metrics/MethodLength

  private

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
end
