module Cms::Model::Member
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Model::Member
  include SS::Reference::Site
  include Cms::SitePermission

  included do
    store_in collection: "cms_members"
    set_permission_name "cms_members", :edit

    field :site_email, type: String

    before_validation :set_site_email, if: ->{ email.present? }
  end

  private
    def set_site_email
      self.site_email = "#{site_id}_#{email}"
    end
end
