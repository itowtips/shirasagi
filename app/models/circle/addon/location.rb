module Circle::Addon
  module Location
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :locations, class_name: "Circle::Node::Location"
      permit_params location_ids: []
    end
  end
end
