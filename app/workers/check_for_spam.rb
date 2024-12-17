# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Workers
  class CheckForSpam < Base
    sidekiq_options queue: :urgent

    def perform(record_type, record_guid)
      record_class = record_type.constantize
      message      = record_class.find_by(guid: record_guid)
      check_for_spam(message)
    end

    # Checks the given message for spam and updates its spam status.
    # The method sends the content of the message to an external spam detection service.
    # Logs the outcome of the spam check (successful or error).
    #
    # - Skips spam checking if the message is non-English.
    # - Skips spam checking if the message text is shorter than the minimum defined length (25 characters).
    # - Sends a POST request to a spam detection endpoint with the message text as the input.
    # - Updates the message’s spam status and timestamp based on the detection result.
    # - Logs warnings or errors in case of service failure or unexpected responses.
    #
    # @param [Object] message The message object containing text and metadata to be checked for spam.
    # @return [void]
    def check_for_spam(message)
      return if message_is_non_english(message)
      return if min_size?(message) # Maybe set this as a configurable value

      log_info_texts(message)
      result = query_spam_detector(message)

      handle_result(message, result)
    rescue StandardError => e
      logger.error("Error with #{e.inspect}")
    end

    private

    def handle_result(message, result)
      if defined?(result["spam"])
        logger.warn("Spam received on #{message.model_name} with id #{message.guid}") if result["spam"]

        message.update_columns(spam_checked_on: Time.zone.now, spam: result["spam"]) # rubocop:disable Rails/SkipsModelValidations
        # TODO: Remove? Mail? - Sind schon etwas unzuverläsig.. Meldung machen?
        # comment.destroy if result["spam"]
      else
        logger.warn("Could not generate spam detection on #{message.model_name} with id #{message.guid}")
      end
    end

    def log_info_texts(message)
      logger.info("Check for spam on #{message.model_name} with id #{message.guid}")
      logger.error("Can not find #{message.model_name} with gui #{record_guid}") if message.nil?
    end

    def min_size?(message)
      message.text.to_s.length > 25
    end

    # Only posts with english texts should be tested for spams for now
    # All other languages do not work
    def message_is_non_english(message)
      message.language_id != "en"
    end

    def query_spam_detector(message)
      prompt            = message.text
      uri               = URI.parse("http://127.0.0.1:8000/check")
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = true if uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 10
      request           = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({prompt: prompt})
      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end
