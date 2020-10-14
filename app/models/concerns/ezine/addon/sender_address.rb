module Ezine::Addon
  module SenderAddress
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :sender_name, type: String, default: ""
      field :sender_email, type: String, default: ""
      field :i18n_sender_name, type: String, localize: true
      permit_params :sender_name, :sender_email, i18n_sender_name_translations: {}
    end
  end
end
