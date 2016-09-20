class Facility::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  helper Map::MapHelper
  append_view_path "app/views/facility/agents/addons/search_setting/view"
  append_view_path "app/views/facility/agents/addons/search_result/view"

  private
    def set_query
      @keyword      = params[:keyword]
      @category_ids = params[:category_ids].select(&:present?).map(&:to_i) rescue []
      @service_ids  = params[:service_ids].select(&:present?).map(&:to_i) rescue []
      @location_ids = params[:location_ids].select(&:present?).map(&:to_i) rescue []

      @q_category = @category_ids.present? ? { category_ids: @category_ids } : {}
      @q_service  = @service_ids.present? ? { service_ids: @service_ids } : {}
      @q_location = @location_ids.present? ? { location_ids: @location_ids } : {}

      @categories = Facility::Node::Category.site(@cur_site).in(_id: @category_ids)
      @services   = Facility::Node::Service.site(@cur_site).in(_id: @service_ids)
      @locations  = Facility::Node::Location.site(@cur_site).in(_id: @location_ids)
    end

    def set_items
      @items = Facility::Node::Page.site(@cur_site).and_public.
        where(@cur_node.condition_hash).
        search(name: @keyword).
        in(@q_category).
        in(@q_service).
        in(@q_location).
        order_by(name: 1).
        page(params[:page]).
        per(@cur_node.limit)
    end

    def set_markers
      limit = @cur_node.map_points_limit.to_i
      @items = Facility::Node::Page.site(@cur_site).and_public.
        where(@cur_node.condition_hash).
        search(name: @keyword).
        in(@q_category).
        in(@q_service).
        in(@q_location).
        order_by(name: 1)
      @items = @items.page(params[:page]).per(limit) if limit > 0
      @markers = @items.pluck(:map_points).flatten.compact
    end

    def set_filter_items
      @filter_categories = @cur_node.st_categories.in(_id: @items.pluck(:category_ids).flatten)
      @filter_locations = @cur_node.st_locations.select{ |l| l.center_point[:loc].present? }
      @focus_options = @filter_locations.map do |l|
        opts = {}
        opts["data-zoom-level"] = l.center_point[:zoom_level] if l.center_point[:zoom_level]
        [l.name, l.center_point[:loc].join(","), opts]
      end
      @focus_options.unshift [I18n.t("facility.select_location"), ""]
    end

  public
    def index
      set_query
      render :index, locals: { search_path: "./map.html" }
    end

    def map
      set_query
      set_markers
      set_filter_items
      @current = "map"
      render :map
    end

    def result
      set_query
      set_items
      @current = "result"
      render :result
    end

    def map_all
      params[:category_ids] = nil
      params[:service_ids]  = nil
      params[:location_ids] = nil
      map
    end
end
