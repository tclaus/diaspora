# frozen_string_literal: true
#
require "net/http"
require "uri"
require "json"

module Workers
  class CheckForSpam < Base
    sidekiq_options queue: :urgent

    def perform(record_type, record_guid)
      record_class = record_type.constantize
      message = record_class.find_by(guid: record_guid)
      check_for_spam(message)
    end

    def check_for_spam(message)
      return if message_is_non_english(message)

      logger.info("Check for spam on #{message.model_name} with id #{message.guid}")

      logger.error("Can not find #{message.model_name} with gui #{record_guid}") if message.nil?

      prompt            = message.text
      uri               = URI.parse("http://127.0.0.1:8000/check")
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true if uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 10
      request           = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({prompt: prompt})
      response = http.request(request)
      result   = JSON.parse(response.body)

      if defined?(result["spam"])
         logger.warn("Spam received on #{message.model_name} with id #{message.guid}") if result["spam"]

        message.update(spam_checked_on: Time.now, spam: result["spam"])
        # TODO: Remove? Mail?
        # comment.destroy if result["spam"]
      else
        logger.warn("Could not generate spam detection on #{message.model_name} with id #{message.guid}")
      end

    rescue StandardError => e
      logger.error("Error with #{e.inspect}")
    end

    private

    # Only posts with english texts should be tested for spams for now
    # All other languages do not work
    def message_is_non_english(message)
      message.language_id != "en"
    end

  end
end
