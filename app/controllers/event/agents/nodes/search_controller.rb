class Event::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  include Event::EventHelper
  helper Event::EventHelper
  helper Cms::ListHelper

  def index
    set_params
    set_start_date
    set_categories
    set_event_pages
    set_facilities
    set_items
    set_markers

    render_with_pagination @items
  end

  def result
    set_params
    set_categories
    set_event_pages
    set_facilities
    set_items
    set_markers

    render :index
  end

  private

  def set_params
    safe_params = params.permit(:search_keyword, :facility_id, category_ids: [], event: [ :start_date, :close_date])
    @keyword = safe_params[:search_keyword].presence
    @category_ids = safe_params[:category_ids].presence || []
    @category_ids = @category_ids.map(&:to_i)
    if params[:event].present? && params[:event][0].present?
      @start_date = params[:event][0][:start_date].presence
      @close_date = params[:event][0][:close_date].presence
    end
    @start_date = Date.parse(@start_date) if @start_date.present?
    @close_date = Date.parse(@close_date) if @close_date.present?
    @facility_id = safe_params[:facility_id].presence
    if @facility_id.present?
      @facility_ids = Facility::Node::Page.site(@cur_site).where(id: @facility_id).and_public.pluck(:id)
    end
  end

  def set_start_date
    @start_date ||= Time.zone.today
  end

  def set_categories
    @categories = []
    return unless @cur_node.parent

    @categories = Cms::Node.site(@cur_site).
      where({:id.in => @cur_node.parent.st_category_ids}).
      sort(filename: 1).to_a
  end

  def set_event_pages
    @event_pages = Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      where('event_dates.0' => { "$exists" => true })
  end

  def set_facilities
    facility_ids = @event_pages.pluck(:facility_id, :facility_ids).flatten.compact
    @facilities = Facility::Node::Page.site(@cur_site).and_public.
      in(id: facility_ids).order_by(kana: 1, name: 1).to_a
  end

  def set_items
    criteria = @event_pages

    if @keyword.present?
      criteria = criteria.search(keyword: @keyword)
    end

    if @category_ids.present?
      criteria = criteria.in(category_ids: @category_ids)
    end

    if @facility_id.present?
      criteria = criteria.or([
        { facility_ids: { "$in": @facility_ids } },
        { facility_id: { "$in": @facility_ids } }
      ])
    end

    if @start_date.present? && @close_date.present?
      criteria = criteria.search(dates: @start_date..@close_date)
    elsif @start_date.present?
      criteria = criteria.search(start_date: @start_date)
    elsif @close_date.present?
      criteria = criteria.search(close_date: @close_date)
    end

    @items = criteria.order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end

  def set_markers
    @markers = []
    @items.each do |item|
      item = item.becomes_with_route

      if item.respond_to?(:map_points) && item.map_points.present?

        # page has map_points
        item.map_points.each do |map_point|
          map_point[:html] = view_context.render_map_point_info(item, map_point)
          map_point[:number] = ""
          @markers << map_point
        end

      elsif item.respond_to?(:facility) && item.facility.present?

        # page has related facility_id's map_points
        facility = item.facility
        facility_map = Facility::Map.site(@cur_site).and_public.
          where(filename: /^#{::Regexp.escape(facility.filename)}\//, depth: facility.depth + 1).order_by(order: 1).first
        next if facility_map.nil?

        facility_map.map_points.each do |map_point|
          map_point[:html] = view_context.render_facility_info(facility, map_point[:loc])
          map_point[:number] = ""
          @markers << map_point
        end

      elsif item.respond_to?(:facilities) && item.facilities.present?

        # page has related facility_ids's map_points
        item.facilities.each do |facility|
          facility_map = Facility::Map.site(@cur_site).and_public.
            where(filename: /^#{::Regexp.escape(facility.filename)}\//, depth: facility.depth + 1).order_by(order: 1).first
          next if facility_map.nil?

          facility_map.map_points.each do |map_point|
            map_point[:html] = view_context.render_facility_info(facility, map_point[:loc])
            map_point[:number] = ""
            @markers << map_point
          end
        end

      end
    end
  end

  def event_end_date(event)
    event_dates = event.get_event_dates
    return if event_dates.blank?

    event_range = event_dates.first

    if event_dates.length == 1
      end_date = ::Icalendar::Values::Date.new(event_range.last.tomorrow.to_date)
    else # event_dates.length > 1
      dates = event_dates.flatten.uniq.sort
      event_range = ::Icalendar::Values::Array.new(dates, ::Icalendar::Values::Date, {}, { delimiter: "," })
      end_date = ::Icalendar::Values::Date.new(event_range.last.tomorrow.to_date)
    end
    end_date
  end
end
