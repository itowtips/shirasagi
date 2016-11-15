module Cms::Addon
  module HideAddonSetting
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :hide_addons, type: SS::Extensions::Words
      permit_params hide_addons: []
    end
  end
end
