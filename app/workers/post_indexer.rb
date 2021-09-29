# frozen_string_literal: true

module Workers
  class PostIndexer < Base
    sidekiq_options queue: :elasticsearch, retry: false

    def perform(operation, record_id)
      return if ES_CLIENT.nil? || Rails.env.test?

      logger.debug [operation, "ID: #{record_id}"]
      case operation.to_s
      when /index/
        record = Post.find(record_id)
        ES_CLIENT.index index: "posts", type: "_doc", id: record.id, body: record.__elasticsearch__.as_indexed_json
      when /delete/
        begin
          ES_CLIENT.delete index: "posts", type: "_doc", id: record_id
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          logger.debug "Post not found, ID: #{record_id}"
        end
      else raise ArgumentError, "Unknown operation: #{operation}"
      end
    end
  end
end
