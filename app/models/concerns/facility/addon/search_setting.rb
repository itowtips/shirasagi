module Facility::Addon
  module SearchSetting
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    included do
      field :limit, type: Integer, default: 100
      field :map_points_limit, type: Integer, default: 0
      field :search_html, type: String

      permit_params :search_html, :limit, :map_points_limit
    end

    public
      def sort_hash
        return { filename: 1 } if sort.blank?
        { sort.sub(/ .*/, "") => (sort =~ /-1$/ ? -1 : 1) }
      end

      def limit
        value = self[:limit].to_i
        (value < 1 || 1000 < value) ? 100 : value
      end
  end
end
