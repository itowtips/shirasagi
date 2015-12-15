module Cms::Addon
  module AdditionalSecretInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :additional_secret_info, type: Cms::Extensions::AdditionalInfo

      permit_params additional_secret_info: [ :field, :value ]
    end
  end
end
