module Opendata::Addon::Harvest::License
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    field :ckan_license_keys, type: SS::Extensions::Lines, default: []
    permit_params :ckan_license_keys
  end
end
