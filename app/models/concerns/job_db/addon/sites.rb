module JobDb::Addon
  module Sites
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :sites, class_name: "Cms::Site"

      scope :site, ->(site) { self.in(site_ids: site.id) }

      permit_params site_ids: []
    end
  end
end
