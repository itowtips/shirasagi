module SS::Addon
  module Translate::SiteSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :translate_state, type: String, default: "disabled"
      field :translate_source, type: String, default: "ja"
      field :translate_targets, type: SS::Extensions::Lines, default: []
      field :translate_api, type: String

      # mock
      field :translate_mock_api_request_count, type: Integer, default: 0
      field :translate_mock_api_request_word_count, type: Integer, default: 0
      field :translate_mock_api_request_metered_usage, type: Integer, default: 0

      # microsoft api
      field :translate_microsoft_api_key, type: String
      field :translate_microsoft_api_request_count, type: Integer, default: 0
      field :translate_microsoft_api_request_word_count, type: Integer, default: 0
      field :translate_microsoft_api_request_metered_usage, type: Integer, default: 0

      permit_params :translate_state
      permit_params :translate_source
      permit_params :translate_targets
      permit_params :translate_api

      permit_params :translate_mock_api_request_count
      permit_params :translate_mock_api_request_word_count
      permit_params :translate_mock_api_request_metered_usage

      permit_params :translate_microsoft_api_key
      permit_params :translate_microsoft_api_request_count
      permit_params :translate_microsoft_api_request_word_count
      permit_params :translate_microsoft_api_request_metered_usage

      validate :validate_translate_targets, if: -> { translate_targets.present? }
    end

    def validate_translate_targets
      self.translate_targets = translate_targets.select(&:present?).map(&:strip)
    end

    def translate_state_options
      [
        [I18n.t("ss.options.state.enabled"), "enabled"],
        [I18n.t("ss.options.state.disabled"), "disabled"],
      ]
    end

    def translate_api_options
      I18n.t("translate.options.api").map { |k, v| [v, k] }
    end

    def translate_enabled?
      translate_state == "enabled"
    end

    def translate_path(target)
      ::File.join(path, "translate", target)
    end
  end
end
