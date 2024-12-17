# frozen_string_literal: true

class AddSpamFieldsToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :spam, :boolean
    add_column :comments, :spam_checked_on, :datetime
  end
end
