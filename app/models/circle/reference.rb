module Circle::Reference
  module Category
    extend ActiveSupport::Concern

    included do
      embeds_ids :categories, class_name: "Circle::Node::Category"
      permit_params category_ids: []

      embeds_ids :st_categories, class_name: "Circle::Node::Category"
      permit_params st_category_ids: []
    end
  end

  module Location
    extend ActiveSupport::Concern

    included do
      embeds_ids :locations, class_name: "Circle::Node::Location"
      permit_params location_ids: []

      embeds_ids :st_locations, class_name: "Circle::Node::Location"
      permit_params st_location_ids: []
    end
  end
end
