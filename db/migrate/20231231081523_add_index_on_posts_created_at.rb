# frozen_string_literal: true

class AddIndexOnPostsCreatedAt < ActiveRecord::Migration[6.1]
  def change
    # Adds a index on created_at with autor_id for statistics

    Post.connection.execute("
      CREATE INDEX IF NOT EXISTS index_posts_on_created_at
      ON public.posts USING btree
      (created_at ASC NULLS LAST)
      INCLUDE(author_id)
      WITH (deduplicate_items=True)
      TABLESPACE pg_default;
    ")
  end
end
