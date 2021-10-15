class Event::Agents::Nodes::PippiSearchController < ApplicationController
  include Cms::NodeFilter::View
  include Event::EventHelper
  helper Event::EventHelper
  helper Cms::ListHelper

  before_action :set_event_node
  before_action :set_params

  def index
    @items = []
    if @keyword.present? || @location_id.present? || @facility_id.present? || @genre_ids.present? || @age_ids.present?
      list_events
    end
  end

  private

  def set_event_node
    @event_node = Event::Node::PippiPage.site(@cur_site).and_public.in_path(@cur_node.filename).first
  end

  def set_params
    safe_params = params.permit(:search_keyword, :location_id, :facility_id, genre_ids: [], age_ids: [])
    @keyword = safe_params[:search_keyword].presence
    @location_id = safe_params[:location_id].to_i.nonzero?
    @location = @event_node.st_locations.site(@cur_site).and_public.where(id: @location_id).first
    @facility_id = safe_params[:facility_id].to_i.nonzero?
    @facility = @event_node.st_facilities.site(@cur_site).and_public.where(id: @facility_id).first
    @genre_ids = safe_params[:genre_ids].presence || []
    @genre_ids = @genre_ids.map(&:to_i)
    @genres = @event_node.st_genres.site(@cur_site).and_public.in(id: @genre_ids)
    @age_ids = safe_params[:age_ids].presence || []
    @age_ids = @age_ids.map(&:to_i)
    @ages = @event_node.st_ages.site(@cur_site).and_public.in(id: @age_ids)
  end

  def list_events
    criteria = Cms::Page.site(@cur_site).and_public
    criteria = criteria.search(keyword: @keyword) if @keyword.present?
    criteria = criteria.where(@cur_node.condition_hash)
    criteria = criteria.exists(event_dates: 1)
    category_ids = [@location_id] + @genre_ids + @age_ids
    category_ids = category_ids.uniq.compact
    criteria = criteria.in(category_ids: category_ids) if category_ids.present?
    criteria = criteria.where(facility_ids: @facility_id) if @facility_id.present?

    @items = criteria.order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end
end
