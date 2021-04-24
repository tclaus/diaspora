# frozen_string_literal: true

class AddUserFieldsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :reported_diaspora_handle, :string, index: true

    Report.find_each do |report|
      # get author from reports that have not deleted item yet
      unless report.reported_author.nil?
        report.reported_diaspora_handle = report.reported_author.diaspora_handle
        report.save(validate: false, touch: false)
      end
      if report.item.nil?
        report.action = "Deleted"
        report.save(validate: false, touch: false)
      end
    end
  end
end
