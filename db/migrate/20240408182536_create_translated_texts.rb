class CreateTranslatedTexts < ActiveRecord::Migration[6.1]
  def change
    create_table :translated_texts  do |t|
      t.string :message_uid
      t.string :hashed_original_text
      t.string :original_language_id
      t.string :translated_language_id
      t.text :translated_text
      t.integer :hits, default: 1
      t.timestamps
    end
    add_index :translated_texts, :message_uid
    add_index :translated_texts, :translated_language_id
  end
end
