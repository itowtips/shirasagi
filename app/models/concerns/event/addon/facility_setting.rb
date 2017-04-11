module Event::Addon
  module FacilitySetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      belongs_to :st_facility_search, class_name: "Facility::Node::Search"
      permit_params :st_facility_search_id
    end
  end
end
