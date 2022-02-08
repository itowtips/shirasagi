module Riken::Addon::ShibbolethSetting
  extend ActiveSupport::Concern
  extend SS::Addon

  included do
    field :login_url, type: String
    permit_params :login_url
    validates :login_url, presence: true, url: true
  end
end
