module Ezine::Addon
  module Body
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :html, type: String, default: ""
      field :text, type: String, default: ""
      field :i18n_html, type: String, localize: true
      field :i18n_text, type: String, localize: true
      permit_params :html, :text, i18n_html_translations: {}, i18n_text_translations: {}
      # validate :validate_text
      validate :validate_i18n_text
    end

    private

    def validate_text
      if html.blank? && text.blank?
        errors.add(:text, :blank)
      end
    end

    def validate_i18n_text
      site = self.site || cur_site
      return if site.blank? || !site.translate_enabled?
      translate_targets.each do |target|
        next if target.id == site.translate_source_id
        if i18n_html_translations[target.code].blank? && i18n_text_translations[target.code].blank?
          errors.add :i18n_text, :blank
        end
      end
    end
  end
end
