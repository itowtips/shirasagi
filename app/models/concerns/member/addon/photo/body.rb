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
      validate :validate_in_image

      after_save :update_relation_image_member
    end

    def validate_image
      errors.add :image, :empty if !image && !in_image
    end

    def update_relation_image_member
      return unless member
      image.update_attributes(member_id: member.id)
    end
  end
end
