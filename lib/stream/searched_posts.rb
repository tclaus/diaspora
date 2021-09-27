# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Stream
  class SearchedPosts < Stream::Base
    attr_accessor :query, :page

    def initialize(user, opts={})
      self.query = opts[:query]
      self.page = (opts[:page] || 1).to_i
      super(user, opts)
    end

    def display_query
      @display_query ||= query.to_s
    end

    def posts
      @posts ||= if user
                   StatusMessage.user_query_stream(user, query, page)
                 else
                   # TODO: Without logged in User - should not be in use?
                   StatusMessage.public_tag_stream(tag.id)
                 end
    end

    def stream_posts
      return [] unless query

      posts.for_a_queried_stream(order, @user)
    end

    private

    # @return [Hash]
    def publisher_opts
      {open: true}
    end
  end
end
