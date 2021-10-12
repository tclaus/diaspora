# frozen_string_literal: true

namespace :diaspora do
  desc "Gathers language usages in oembed cached"
  task gather_oembed_languages: :environment do
    OpenGraphCache.where(locale: nil).find_in_batches do |openGraphCaches|
      openGraphCaches.each do |og|
        puts "Fetches language for: #{og.url}"
        og.fetch_and_save_opengraph_data!
        rescue =>e
          puts "Error: #{e}"
      end
    end
  end

  desc "Updates languages of posts that only have language set by an oembed"
  task update_post_language_by_oembed_language: :environment do
    Post.where.not(open_graph_cache_id: nil).find_in_batches do |batch|
      batch.each do |post|
        if post.contains_open_graph_url_in_text?
          post.queue_gather_open_graph_data
        end
      end
    end
  end
end
