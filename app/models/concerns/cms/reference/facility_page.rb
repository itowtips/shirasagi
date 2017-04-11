module Cms::Reference
  module FacilityPage
    extend ActiveSupport::Concern
    extend SS::Translation

    included do
      embeds_ids :facility_pages, class_name: "Facility::Node::Page"
      permit_params facility_page_ids: []
    end
  end
end
