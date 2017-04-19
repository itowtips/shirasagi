class Event::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  include Event::EventHelper
  helper Event::EventHelper
  helper Cms::ListHelper

  before_action :set_params

  def index
  end

  def search
    list_events
  end

  def map
    raise "404" if @cur_node.search_url_state == "index"
    list_events
    set_markers
  end

  def list
    raise "404" if @cur_node.search_url_state == "index"
    list_events
  end

  private
    def set_params
      safe_params = params.permit(:search_keyword, category_ids: [], event: [ :start_date, :close_date])
      @keyword = safe_params[:search_keyword].presence
      @category_ids = safe_params[:category_ids].presence || []
      @category_ids = @category_ids.map(&:to_i)
      if params[:event].present? && params[:event][0].present?
        @start_date = params[:event][0][:start_date].presence
        @close_date = params[:event][0][:close_date].presence
      end
      @start_date = Date.parse(@start_date) if @start_date.present?
      @close_date = Date.parse(@close_date) if @close_date.present?
      @facility = Facility::Node::Page.find(params[:facility_id].to_i) rescue nil

      if @cur_node.parent
        @categories = Cms::Node.site(@cur_site).where({:id.in => @cur_node.parent.st_category_ids}).sort(filename: 1)
        @select_categories = @categories.to_a.select { |item| @category_ids.index(item.id) }
      else
        @categories = []
        @select_categories = []
      end
      facility_page_ids = Cms::Page.site(@cur_site).and_public(@cur_date).where(@cur_node.condition_hash).pluck(:facility_page_ids).flatten.compact
      @facility_options = Facility::Node::Page.in(id: facility_page_ids).map { |item| [ item.name, item.id ] }
    end

    def list_events
      criteria = Cms::Page.site(@cur_site).and_public
      criteria = criteria.search(name: @keyword) if @keyword.present?
      criteria = criteria.where(@cur_node.condition_hash)
      criteria = criteria.in(category_ids: @category_ids) if @category_ids.present?
      criteria = criteria.in(facility_page_ids: @facility.id) if @facility.present?

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

    def set_markers
      @markers = []

      return if @items.blank?
      @items.each do |item|
        item = item.becomes_with_route

        if item.respond_to?(:facility_pages) && item.facility_pages.and_public(@cur_date).present?
          item.facility_pages.and_public(@cur_date).each do |page|
            page.map_pages.and_public(@cur_date).each do |map_page|
              map_page.map_points.each do |point|
                h = []
                h << "<p><a href=\"#{page.url}\">#{page.name}</a></p><br />"
                h << "<p>直近開催のイベント</p>"
                page.event_pages.each do |event_page|
                  h << "<p><a href=\"#{event_page.url}\">#{event_page.name}</a></p>"
                end
                point[:html] = h.join
                @markers.push point
              end
            end
          end
        elsif item.respond_to?(:map_points) && item.map_points.present?
          item.map_points.each do |point|
            @markers.push point
          end
        end
      end
    end
end
