module Circle::Addon
  module Category
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :categories, class_name: "Circle::Node::Category"
      permit_params category_ids: []
    end

    set_order 300
  end
end
