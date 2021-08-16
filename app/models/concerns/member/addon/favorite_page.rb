module Member::Addon
  module FavoritePage
    extend SS::Addon
    extend ActiveSupport::Concern

    included do
      field :link_name, type: String
      permit_params :link_name
    end
  end
end
