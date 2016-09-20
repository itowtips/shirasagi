module Facility::Addon
  module SearchSetting
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    included do
      field :search_html, type: String
      field :map_points_limit, type: Integer, default: 0

      before_validation :set_map_points_limit

      permit_params :search_html, :map_points_limit
    end

    def sort_hash
      return { filename: 1 } if sort.blank?
      { sort.sub(/ .*/, "") => (sort =~ /-1$/ ? -1 : 1) }
    end

    def set_map_points_limit
      self.map_points_limit = 0 if map_points_limit.to_i <= 0
    end
  end
end
