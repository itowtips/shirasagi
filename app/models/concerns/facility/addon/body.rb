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
      field :email, type: String
      field :related_url, type: String

      permit_params :kana, :postcode, :address, :tel, :fax, :email, :related_url
    end
  end
end
