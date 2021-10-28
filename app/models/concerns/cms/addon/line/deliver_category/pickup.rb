module Cms::Addon
  module Line::DeliverCategory::Pickup
    extend ActiveSupport::Concern
    extend SS::Addon

    def child_page_node
      @_child_page_node ||= Category::Node::Base.site(site).where(name: "年齢別").first
    end
  end
end
