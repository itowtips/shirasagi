module Rss::Addon
  module Urgency
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :urgency_state, type: String, default: "disabled"
      field :urgency_target_page_filename, type: String

      belongs_to :urgency_default_layout, class_name: "Cms::Layout"
      belongs_to :urgency_layout, class_name: "Cms::Layout"

      field :from_email, type: String
      field :notice_email, type: String

      permit_params :urgency_state, :urgency_target_page_filename
      permit_params :urgency_layout_id, :urgency_default_layout_id
      permit_params :from_email, :notice_email
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
      Rails.logger.info("urgency layout switcher")
      page = Cms::Page.site(site).where(filename: urgency_target_page_filename).first

      if page.layout_id != layout.id
        before_layout_name = page.layout.name
        after_layout_name = layout.name

        Rails.logger.info("switch #{page.layout.name}(#{page.layout.id}) to #{layout.name}(#{layout.id})")

        page.layout = layout
        page.save!(:validate => false)

        if notice_email.present?
          Rss::Mailer.urgency_notify_mail(self, before_layout_name, after_layout_name).deliver_now
        end
      end
    rescue => e
      Rails.logger.info("#switch_layout failer (#{e.message}):\n  #{e.backtrace.join("\n  ")}")
    end

    def switch_to_default_layout
      switch_layout(urgency_default_layout)
    end

    def switch_to_urgency_layout
      switch_layout(urgency_layout)
    end
  end
end
