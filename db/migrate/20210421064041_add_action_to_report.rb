# frozen_string_literal: true

class AddActionToReport < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :action, :string

    Report.update_all(action: Report::STATUS_NO_ACTION)
  end
end
