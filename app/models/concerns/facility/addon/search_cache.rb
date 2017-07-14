module Facility::Addon
  module SearchCache
    extend ActiveSupport::Concern
    extend SS::Addon
    include Map::MapHelper

    EARTH_RADIUS_KM = 6378.137

    included do
      before_save :set_map_points
      before_save :set_sidebar_html

      field :map_points, type: Array, default: []
      field :sidebar_html, type: String, default: ""
    end

    def set_map_points
      self.map_points = []
      maps = Facility::Map.site(site).and_public.where(filename: /^#{filename}\//, depth: depth + 1)

      category_ids = categories.map(&:id)
      image_id = categories.map(&:image_id).first
      image_url = SS::File.find(image_id).url rescue nil
      points = maps.first.map_points rescue nil

      marker_info = render_marker_info_include_directions(self, points)
      map_points = maps.each do |map|
        map.map_points.each do |point|
          point[:id] = id
          point[:html] = marker_info
          point[:category] = category_ids
          point[:image] = image_url if image_url.present?
          self.map_points << point
        end
      end
    end

    def set_sidebar_html
      self.sidebar_html = render_map_sidebar(self)
    end

    module ClassMethods
      def center_sphere(loc, radius_km)
        where(
          map_points: {
            "$elemMatch" => {
              "loc" => {
                "$geoWithin" => { "$centerSphere" => [ loc, radius_km / EARTH_RADIUS_KM ] }
              }
            }
          }
        )
      end
    end
  end
end
