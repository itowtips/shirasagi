module Circle::Addon
  module Body
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :activity, type: String
      field :address, type: String
      field :message, type: String
      field :related_url, type: String
      field :hours, type: String
      field :venue, type: String

      permit_params :activity, :address, :message
      permit_params :related_url, :hours, :venue
    end

    set_order 200
  end

  module AdditionalInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :additional_info, type: Circle::Extensions::AdditionalInfo

      permit_params additional_info: [ :field, :value ]
    end

    set_order 210
  end

  module Image
    extend ActiveSupport::Concern
    extend SS::Addon

    set_order 200

    included do
      belongs_to :image, class_name: "Circle::TempFile"

      permit_params :image_id
    end
  end

  module ImageInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    set_order 210

    included do
      field :image_alt, type: String
      field :image_comment, type: String
      field :image_thumb_width, type: Integer, default: 120
      field :image_thumb_height, type: Integer, default: 90

      permit_params :image_alt, :image_comment, :image_thumb_width, :image_thumb_height
    end
  end
end
