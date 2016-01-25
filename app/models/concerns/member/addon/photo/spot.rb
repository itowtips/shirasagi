module Member::Addon::Photo
  module Spot
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :photos, class_name: "Member::Photo"
      permit_params photo_ids: []
    end
  end
end
