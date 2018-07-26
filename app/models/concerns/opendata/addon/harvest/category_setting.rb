module Opendata::Addon::Harvest::CategorySetting
  extend SS::Addon
  extend ActiveSupport::Concern

  included do
    embeds_ids :default_categories, class_name: 'Opendata::Node::Category'
    has_many :category_settings, class_name: 'Opendata::Harvest::CategorySetting', dependent: :destroy, inverse_of: :harvest

    permit_params default_category_ids: []
  end
end
