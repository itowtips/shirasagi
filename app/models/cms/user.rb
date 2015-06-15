class Cms::User
  include SS::Model::User
  include Cms::Addon::Role
  include Cms::Reference::Role
  include Cms::SitePermission

  set_permission_name "cms_users", :edit

  validate :validate_groups

  scope :site, ->(site) { self.in(group_ids: Cms::Group.site(site).pluck(:id)) }

  private
    def validate_groups
      self.errors.add :group_ids, :blank if groups.blank?
    end
end
