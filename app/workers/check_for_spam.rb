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
      logger.info("Check for spam on #{message.model_name} with id #{record_guid}")

      logger.error("Can not find #{record_type} with gui #{record_guid}") if message.nil?

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
         logger.warn("Spam received on #{message.model_name} with id #{record_guid}") if result["spam"]

        message.update(spam_checked_on: Time.now, spam: result["spam"])
        # TODO: Remove? Mail?
        # comment.destroy if result["spam"]
      else
        # retry
      end

    rescue StandardError => e
      # retry
    end
  end
end
