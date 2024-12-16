class AddLanguageIdToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :language_id, :string
  end
end
