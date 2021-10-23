# frozen_string_literal: true

class RemoveLanguageReliabeFromPosts < ActiveRecord::Migration[5.2]
  def up
    Post.update_all(language_id: nil, language_reliable: false)
    remove_column :posts, :language_reliable
  end
end
