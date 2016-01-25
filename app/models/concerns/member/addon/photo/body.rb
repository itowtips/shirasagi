module Member::Addon::Photo
  module Body
    extend ActiveSupport::Concern
    extend SS::Addon
    include SS::Relation::File

    included do
      belongs_to_file :image, class_name: "Member::PhotoFile"
      field :caption, type: String

      permit_params :caption, :image_id, :loc
      validate :validate_image
    end

    def validate_image
      errors.add :image, :empty if !image && !in_image
    end
  end
end
