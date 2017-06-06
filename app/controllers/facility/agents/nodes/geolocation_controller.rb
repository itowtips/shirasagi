class Facility::Agents::Nodes::GeolocationController < ApplicationController
  include Cms::NodeFilter::View
  helper Map::MapHelper

  before_action :set_loc

  private
    def set_loc
      @lat = params[:lat]
      @lon = params[:lon]
      @radius = params[:r].to_i
      @radius = 5 if @radius <= 0 || @radius > 30

      return unless @lat =~ /\d+(\.\d+)?/
      return unless @lon =~ /\d+(\.\d+)?/

      @lat = @lat.to_f
      @lon = @lon.to_f

      if @lat >= -90 && @lat <= 90 && @lon >= -180 && @lon <= 180
        @loc = [@lon, @lat]
      end
    end

  public
    def index
      @items = []
      @markers = []

      return unless @loc

      images = SS::File.all.map {|image| [image.id, image.url]}.to_h
      Facility::Map.site(@cur_site).and_public.where(@cur_node.condition_hash).center_sphere(@loc, @radius).each do |map|
        parent_path = ::File.dirname(map.filename)
        item = Facility::Node::Page.site(@cur_site).and_public.in_path(parent_path).first

        next unless item
        @items << item
        category_ids = item.categories.map(&:id)

        image_id = item.categories.map(&:image_id).first
        image_url = images[image_id]

        marker_info  = view_context.render_marker_info(item)

        map.map_points.each do |point|
          point[:id] = item.id
          point[:html] = marker_info
          point[:category] = category_ids
          point[:image] = image_url if image_url.present?
          @markers.push point
        end
      end

      set_filter_items
    end

  private
    def set_filter_items
      @filter_categories = @cur_node.st_categories.in(_id: @items.map(&:category_ids).flatten)
      @filter_locations = @cur_node.st_locations.entries.select{ |l| l.center_point[:loc].present? }
    end
end
