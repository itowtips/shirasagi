module Translate::Addon::Lang::Page
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    field :i18n_name, type: String, localize: true
    embeds_ids :translate_targets, class_name: "Translate::Lang"
    define_method(:translate_targets) do
      items = ::Translate::Lang.in(id: translate_target_ids).to_a
      translate_target_ids.map { |id| items.find { |item| item.id == id } }
    end

    permit_params i18n_name_translations: {}, translate_target_ids: []

    validate :validate_i18n_name
  end

  private

  def validate_i18n_name
    site = self.site || cur_site
    return if site.blank? || !site.translate_enabled?
    translate_targets.each do |target|
      next if target.id == site.translate_source_id
      errors.add :i18n_name, :blank if i18n_name_translations[target.code].blank?
    end
  end
end
