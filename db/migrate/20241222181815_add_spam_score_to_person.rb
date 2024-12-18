# frozen_string_literal: true

class AddSpamScoreToPerson < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :spam_score, :float
  end
end
