module Circle::Addon::Location
  module Setting
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :st_locations, class_name: "Circle::Node::Location"
      permit_params st_location_ids: []
    end

    set_order 520
  end
end
