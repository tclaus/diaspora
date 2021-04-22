# frozen_string_literal: true

class AddUserFieldsToReports < ActiveRecord::Migration[5.2]
  def change
    change_table :reports, bulk: true do |t|
      t.numeric :reported_author_id, index: true
      t.string :action
    end

    Report.find_each do |report|
      # get reported author id from item before item gets deleted
      if report.reported_author.present?
        report.reported_author_id = report.reported_author.id
      end
      if report.item.present?
        report.action = Report::STATUS_NO_ACTION
      end
      report.save(validate: false, touch: false)
    end
  end
end
