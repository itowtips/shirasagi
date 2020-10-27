module Cms::Addon::SiteSearch
  module Keyword
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :site_search_keywords, type: SS::Extensions::Lines
      permit_params :site_search_keywords
    end
  end
end
