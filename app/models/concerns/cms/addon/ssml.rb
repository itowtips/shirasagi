module Cms::Addon
  module Ssml
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :ssml, type: String
      permit_params :ssml
    end
  end
end
