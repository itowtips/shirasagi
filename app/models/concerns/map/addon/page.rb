module Map::Addon
  module Page
    extend ActiveSupport::Concern
    extend SS::Addon

    EARTH_RADIUS_KM = 6378.137

    included do
      field :map_points, type: Map::Extensions::Points, default: []

      permit_params map_points: [ :name, :loc, :text, :link, :image ]
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
