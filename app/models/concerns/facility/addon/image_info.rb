module Facility::Addon
  module ImageInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :image_alt, type: String
      field :image_comment, type: String
      field :image_thumb_width, type: Integer, default: SS.config.facility.thumb_size[0]
      field :image_thumb_height, type: Integer, default: SS.config.facility.thumb_size[1]

      permit_params :image_alt, :image_comment, :image_thumb_width, :image_thumb_height
    end
  end
end
