# frozen_string_literal: true

class SearchHistory < ApplicationRecord
  validates :search_term, presence: true
end
