# frozen_string_literal: true

namespace :diaspora do
  desc "Detects languages uses in posts"
  task import_to_index: :environment do
    # TODO: Run this line:  rake environment elasticsearch:import:model CLASS="Post"
  end
end
