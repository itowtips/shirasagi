class Event::Agents::Parts::PippiSearchController < ApplicationController
  include Cms::PartFilter::View
  helper Event::EventHelper

  before_action :set_event_node
  before_action :set_search_node
  before_action :set_params

  def index
  end

  private

  def set_event_node
    @event_node = Event::Node::PippiPage.site(@cur_site).and_public.in_path(@cur_part.filename).first
  end

  def set_search_node
    @search_node = Event::Node::PippiSearch.site(@cur_site).and_public.in_path(@cur_part.filename).first
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
end
