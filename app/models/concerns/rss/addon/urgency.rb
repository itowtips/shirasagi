module Rss::Addon
  module Urgency
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :urgency_state, type: String, default: "disabled"
      field :urgency_target_page_filename, type: String

      belongs_to :urgency_default_layout, class_name: "Cms::Layout"
      belongs_to :urgency_layout, class_name: "Cms::Layout"

      permit_params :urgency_state, :urgency_target_page_filename
      permit_params :urgency_layout_id, :urgency_default_layout_id
    end

    def urgency_state_options
      [
        [I18n.t("views.options.state.disabled"), "disabled"],
        [I18n.t("views.options.state.enabled"), "enabled"],
      ]
    end

    def urgency_enabled?
      urgency_state == "enabled"
    end

    def switch_layout(layout)
      page = Cms::Page.site(site).where(filename: urgency_target_page_filename).first
      page.layout = layout
      page.update
    end

    def switch_to_default_layout
      switch_layout(urgency_default_layout)
    end

    def switch_to_urgency_layout
      switch_layout(urgency_layout)
    end
  end
end
