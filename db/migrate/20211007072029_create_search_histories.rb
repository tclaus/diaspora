class CreateSearchHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :search_histories do |t|
      t.integer :user_id
      t.string :search_term
      t.timestamps
    end
    add_index :search_histories, :user_id
    add_index :search_histories, :search_term
  end
end
