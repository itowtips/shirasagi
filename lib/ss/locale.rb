module SS::Locale
  def self.to_i18next_resources
    resources = {}
    I18n.available_locales.each do |lang|
      json = I18n.t(".", locale: lang).to_json
      json.gsub!(/%{\w+?}/) do |matched|
        "{{#{matched[2..-2]}}}"
      end

      resources[lang] = { translation: JSON.parse(json) }
    end
    resources
  end

  def self.to_i18next_options
    {
      lng: I18n.default_locale,
      fallbackLng: I18n.fallbacks.defaults,
      resources: SS::Locale.to_i18next_resources
    }
  end
end
