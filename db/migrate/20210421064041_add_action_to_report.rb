# frozen_string_literal: true

class AddActionToReport < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :action, :string

    # rubocop:disable Rails/SkipsModelValidations
    Report.update_all(action: Report::STATUS_NO_ACTION)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
