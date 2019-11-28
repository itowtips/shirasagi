module SS::Addon
  module Translate::SiteSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :translate_state, type: String, default: "disabled"
      field :translate_source_language_code, type: String, default: "ja"
      field :translate_target_language_codes, type: SS::Extensions::Lines
      field :translate_request_count, type: Integer, default: 0
      field :translate_request_word_count, type: Integer, default: 0

      permit_params :translate_request_count
      permit_params :translate_request_word_count
      permit_params :translate_state
      permit_params :translate_source_language_code
      permit_params :translate_target_language_codes
    end

    def translate_state_options
      [
        [I18n.t("ss.options.state.enabled"), "enabled"],
        [I18n.t("ss.options.state.disabled"), "disabled"],
      ]
    end

    def translate_enabled?
      translate_state == "enabled"
    end
  end
end
