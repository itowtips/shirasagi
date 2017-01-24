class IjuSupport::Member
  include JobDb::Model::Member
  include Cms::Addon::GroupPermission

  default_scope ->{ where(kind_ids: 'iju') }

  class << self
    def site(site, opts = {})
      if opts[:state].present?
        self.in(group_ids: Cms::Group.unscoped.site(site).state(opts[:state]).pluck(:id))
      else
        self.in(group_ids: Cms::Group.site(site).pluck(:id))
      end
    end
  end
end
