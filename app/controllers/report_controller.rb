# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ReportController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_moderator, except: [:create]

  def index
    @reports = Report.all.order(created_at: :desc)
    @reports_by_reporter = reports_by_reporter
  end

  def update
    if report = Report.where(id: params[:id]).first
      report.mark_as_reviewed
      report.update(action: "No Action")
    end
    redirect_to :action => :index
  end

  def destroy
    if (report = Report.where(id: params[:id]).first) && report.destroy_reported_item
      flash[:notice] = I18n.t "report.status.destroyed"
    else
      flash[:error] = I18n.t "report.status.failed"
    end
    redirect_to action: :index
  end

  def create
    report = current_user.reports.new(report_params)
    report.reported_diaspora_handle = report.reported_author.diaspora_handle
    if report.save
      render json: true, status: 200
    else
      head :conflict
    end
  end

  private
  def report_params
    params.require(:report).permit(:item_id, :item_type, :text)
  end

  def reports_by_reporter
    sql = "select count(*), user_id, diaspora_handle, guid from reports
           join people on reports.user_id = people.id
           group by user_id, guid, diaspora_handle order by count(*) desc;"
    ActiveRecord::Base.connection.exec_query sql
  end
end
