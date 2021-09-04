class AddLanguageToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :language_id, :string
    add_column :posts, :language_reliable, :boolean
  end
end
