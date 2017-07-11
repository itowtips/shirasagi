class Facility::Agents::Nodes::SearchWithGeolocationController < ApplicationController
  include Cms::NodeFilter::View
  helper Map::MapHelper

  before_action :set_loc

  private
    def set_loc
      @lon= params[:lon]
      @lat = params[:lat]
      @radius = params[:r].to_f
      @radius = 1.0 if @radius <= 0.05 || @radius > 100

      return unless @lat =~ /\d+(\.\d+)?/
      return unless @lon =~ /\d+(\.\d+)?/

      @lat = @lat.to_f
      @lon = @lon.to_f

      if @lat >= -90 && @lat <= 90 && @lon >= -180 && @lon <= 180
        @loc = [@lon, @lat]
      end
    end

    def set_items
      if @loc
        @items = Facility::Node::Page.site(@cur_site).and_public.
          where(@cur_node.condition_hash).
          center_sphere(@loc, @radius)
      else
        @items = Facility::Node::Page.none
      end
      @markers = @items.map do |item|
        points = item.map_points.map do |point|
          point[:facility_name] = item.name
          point[:facility_url] = item.url
          point[:address] = item.address
          point[:ssid] = item.try(:ssid)
          point[:distance] = ::Geocoder::Calculations.distance_between([@lat,@lon], [point["loc"]["lat"], point["loc"]["lng"]], units: :km) rescue 0.0
          point
        end
        points
      end.flatten
      @markers = @markers.sort_by { |point| point[:distance] }
    end

    def set_filter_items
      @filter_categories = @cur_node.st_categories.in(_id: @items.pluck(:category_ids).flatten)
      @radius_options = [["1km", "1.0"], ["3km", "3.0"], ["5km", "5.0"], ["10km", "10.0"], ["30km", "30.0"]]
      @location_options = @cur_node.st_locations.order_by(order: 1).select { |item| item.center_point.present? }.map { |item| [item.name, item.center_point[:loc].values.join(",") ] }
      @location_options.unshift [I18n.t("facility.select_location"), ""]
    end

  public
    def index
      set_items
      set_filter_items
    end
end
