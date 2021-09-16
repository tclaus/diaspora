class CreateStreamLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :stream_languages do |t|
      t.integer :user_id
      t.string :language_id
      t.timestamps
    end
    add_index :stream_languages, :user_id
  end
end
