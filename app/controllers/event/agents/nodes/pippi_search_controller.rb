class Event::Agents::Nodes::PippiSearchController < ApplicationController
  include Cms::NodeFilter::View
  include Event::EventHelper
  helper Event::EventHelper
  helper Cms::ListHelper

  before_action :set_event_node
  before_action :set_params

  def index
    @categories = []
    @items = []
    if @cur_node.parent
      @categories = Cms::Node.site(@cur_site).where({:id.in => @cur_node.parent.st_category_ids}).sort(filename: 1)
    end
    if @keyword.present? || @category_ids.present? || @start_date.present? || @close_date.present? || @facility_ids.present?
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
    @location_id = safe_params[:location_id].presence
    @location = @event_node.st_locations.site(@cur_site).and_public.where(id: @location_id).first
    @facility_id = safe_params[:facility_id].presence
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
    criteria = criteria.in(category_ids: @category_ids) if @category_ids.present?
    criteria = criteria.in(facility_ids: @facility_ids) if @facility_name.present?

    if @start_date.present? && @close_date.present?
      criteria = criteria.search(dates: @start_date..@close_date)
    elsif @start_date.present?
      criteria = criteria.search(start_date: @start_date)
    elsif @close_date.present?
      criteria = criteria.search(close_date: @close_date)
    else
      criteria = criteria.exists(event_dates: 1)
    end

    @items = criteria.order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end
end
