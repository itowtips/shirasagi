module Member::Addon::Photo
  module PippiLicenseSetting
    extend ActiveSupport::Concern
    extend SS::Addon
    include SS::Relation::File

    included do
      field :not_downloadable_html, type: String
      field :cc_by_html, type: String
      belongs_to_file2 :cc_by_image

      permit_params :not_downloadable_html, :cc_by_html
    end
  end
end
