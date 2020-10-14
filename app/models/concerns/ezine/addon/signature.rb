module Ezine::Addon
  module Signature
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :signature_html, type: String, default: ""
      field :signature_text, type: String, default: ""
      field :i18n_signature_html, type: String, localize: true
      field :i18n_signature_text, type: String, localize: true
      permit_params :signature_html, :signature_text, i18n_signature_html_translations: {}, i18n_signature_text_translations: {}
    end
  end
end
