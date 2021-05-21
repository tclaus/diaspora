# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# rubocop:disable Style/ClassAndModuleChildren
class Stream::LocalPublic < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.local_public_stream_path(opts)
  end

  def title
    I18n.translate("streams.local_public.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= Post.all_local_public
  end

  def can_comment?(post)
    post.author.local?
  end

  # Override base class method
  def aspects
    ["public"]
  end
end
# rubocop:enable Style/ClassAndModuleChildren