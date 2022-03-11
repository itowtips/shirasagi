module Riken::Payment
  class ImporterSetting
    include SS::Document
    include ::Riken::Addon::Payment::ServiceSetting
    include Gws::Reference::Site
    include Gws::SitePermission

    set_permission_name "gws_groups", :edit

    field :api_url, type: String
    field :request_title, type: String
    field :remand_title, type: String

    belongs_to :circular_owner, class_name: "Gws::User"
    belongs_to :circular_category, class_name: "Gws::Circular::Category"

    permit_params :api_url, :request_title, :remand_title
    permit_params :circular_owner_id, :circular_category_id

    validates :api_url, presence: true
    validates :request_title, presence: true
    validates :remand_title, presence: true
    validates :circular_owner, presence: true
  end
end
