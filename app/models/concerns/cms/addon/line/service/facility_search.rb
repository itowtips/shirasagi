module Cms::Addon
  module Line::Service::FacilitySearch
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      def categories
        Cms::Line::FacilitySearch::Category.site(site).to_a
      end
    end
  end
end
