module Facility::Addon
  module Body
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :kana, type: String
      field :postcode, type: String
      field :address, type: String
      field :tel, type: String
      field :fax, type: String
      field :related_url, type: String
      field :related_url2, type: String

      permit_params :kana, :postcode, :address, :tel, :fax, :related_url, :related_url2
    end
  end
end
