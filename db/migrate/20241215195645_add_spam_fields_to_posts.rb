class AddSpamFieldsToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :spam, :boolean
    add_column :posts, :spam_checked_on, :datetime
  end
end
