module Opendata::Addon::Harvest::EstatCategorySetting
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    embeds_ids :default_estat_categories, class_name: 'Opendata::Node::EstatCategory'
    has_many :estat_category_settings, class_name: 'Opendata::Harvest::EstatCategorySetting', dependent: :destroy, inverse_of: :harvest

    permit_params default_estat_category_ids: []
  end
end
