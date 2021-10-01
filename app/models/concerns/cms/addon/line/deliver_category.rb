module Cms::Addon
  module Line::DeliverCategory
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :st_categories, class_name: "Category::Node::Base"
      permit_params st_category_ids: []
    end
  end
end
