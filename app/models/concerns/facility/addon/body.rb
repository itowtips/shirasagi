module Facility::Addon
  module Body
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :ssid, type: String
      field :kana, type: String
      field :postcode, type: String
      field :address, type: String
      field :tel, type: String
      field :fax, type: String
      field :related_url, type: String

      permit_params :ssid, :kana, :postcode, :address, :tel, :fax, :related_url
    end
  end
end
