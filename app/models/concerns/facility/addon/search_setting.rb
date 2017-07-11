module Facility::Addon
  module SearchSetting
    extend ActiveSupport::Concern
    extend SS::Addon
    include Cms::Addon::List::Model

    included do
      field :search_html, type: String
      field :map_points_limit, type: Integer, default: 0
      field :search_result_type, type: String

      before_validation :set_map_points_limit

      permit_params :search_html, :map_points_limit, :search_result_type
    end

    def limit
      value = self[:limit].to_i
      (value < 1 || 10000 < value) ? 100 : value
    end

    def sort_hash
      return { filename: 1 } if sort.blank?
      { sort.sub(/ .*/, "") => (sort =~ /-1$/ ? -1 : 1) }
    end

    def set_map_points_limit
      self.map_points_limit = 0 if map_points_limit.to_i <= 0
    end

    def search_result_type_options
      [
        [I18n.t("facility.options.search_result_type.map"), "map"],
        [I18n.t("facility.options.search_result_type.map_only"), "map_only"],
        [I18n.t("facility.options.search_result_type.result"), "result"],
        [I18n.t("facility.options.search_result_type.result_only"), "result_only"],
      ]
    end

    def default_search_result_path
      case search_result_type
        when "map"
          "./map.html"
        when "map_only"
          "./map.html"
        when "result"
          "./result.html"
        when "result_only"
          "./result.html"
        else
          "./map.html"
      end
    end

    def enabled_map_path?
      search_result_type != "result_only"
    end

    def enabled_result_path?
      search_result_type != "map_only"
    end
  end
end
