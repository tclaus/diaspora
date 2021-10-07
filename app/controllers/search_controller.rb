# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!

  def search
    add_to_search_history
    if search_query.starts_with?("#")
      if search_query.length > 1
        respond_to do |format|
          format.json {redirect_to tags_path(q: search_query.delete("#."))}
          format.any {redirect_to tag_path(name: search_query.delete("#."))}
        end
      else
        flash[:error] = I18n.t('tags.show.none', name: search_query)
        redirect_back fallback_location: stream_path
      end
    elsif search_query.include?("@")
      redirect_to people_path(q: search_query)
    elsif params[:format].nil? && AppConfig.elasticsearch.enable
      # TODO: JSON result bauen für instant-answer
      redirect_to stream_path(q: search_query)
    end
  end

  private

  def add_to_search_history

    search_term = search_query.strip
    return unless request.format == :html && search_term.present?

    SearchHistory.create(search_term: search_term)
  end

  def search_query
    @search_query ||= (params[:q] || params[:term] || '').strip
  end

end
