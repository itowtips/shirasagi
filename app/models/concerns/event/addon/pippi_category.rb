module Event::Addon
  module PippiCategory
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      embeds_ids :st_locations, class_name: "Category::Node::Base"
      embeds_ids :st_facilities, class_name: "Facility::Node::Page"
      embeds_ids :st_genres, class_name: "Category::Node::Base"
      embeds_ids :st_ages, class_name: "Category::Node::Base"
      permit_params st_location_ids: [], st_facility_ids: [], st_genre_ids: [], st_age_ids: []
    end
  end
end
