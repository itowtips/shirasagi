module Cms::Addon
  module Html
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :html, type: String, metadata: { unicode: :nfc }
      permit_params :html
    end
  end
end
