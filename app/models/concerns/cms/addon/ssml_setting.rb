module Cms::Addon
  module SsmlSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :st_ssml_state, type: String, default: "disabled"
      permit_params :st_ssml_state
    end

    def ssml_enabled?
      st_ssml_state == "enabled"
    end

    def st_ssml_state_options
      %w(disabled enabled).map { |m| [I18n.t("ss.options.state.#{m}"), m] }
    end
  end
end
