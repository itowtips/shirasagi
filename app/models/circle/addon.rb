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
      field :contact, type: String

      permit_params :activity, :address, :message
      permit_params :related_url, :hours, :venue, :contact
    end
  end

  module AdditionalInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :additional_info, type: Circle::Extensions::AdditionalInfo

      permit_params additional_info: [ :field, :value ]
    end
  end

  module Image
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      belongs_to :image, class_name: "SS::File"
      permit_params :image_id

      before_save :save_image
      after_destroy :destroy_image
    end

    def save_image
      return true unless image_id_changed?
      image.update_attributes(site_id: site_id, model: "circle/file", state: "public") if image

      if image_id_was
        file = SS::File.where(id: image_id_was).first
        file.destroy if file
      end
    end

    def destroy_image
      image.destroy if image
    end
  end

  module ImageInfo
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      field :image_alt, type: String
      field :image_comment, type: String
      field :image_thumb_width, type: Integer, default: 120
      field :image_thumb_height, type: Integer, default: 90

      permit_params :image_alt, :image_comment, :image_thumb_width, :image_thumb_height
    end
  end
end
