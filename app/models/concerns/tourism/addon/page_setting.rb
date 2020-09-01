module Tourism::Addon
  module PageSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :tourism_pages, class_name: "Tourism::Page"
      permit_params tourism_page_ids: []
    end
  end
end
