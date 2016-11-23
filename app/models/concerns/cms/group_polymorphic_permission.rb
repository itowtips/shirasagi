module Cms::GroupPolymorphicPermission
  extend ActiveSupport::Concern
  include SS::Permission

  included do
    field :permission_name, type: String
    before_validation :set_permission_resource_name
  end

  private
    def set_permission_resource_name
      becomes_with_route.class.permission_name
    end

  module ClassMethods
    # @param [String] action
    # @param [Cms::User] user
    def allow(action, user, opts = {})
      site_id = opts[:site] ? opts[:site].id : criteria.selector["site_id"]

      action = permission_action || action

      level = user.cms_role_permissions["#{action}_other_#{permission_name}_#{site_id}"]
      return where("$or" => [{ permission_level: { "$lte" => level }}, { permission_level: nil }]) if level

      level = user.cms_role_permissions["#{action}_private_#{permission_name}_#{site_id}"]
      return self.in(group_ids: user.group_ids).
        where("$or" => [{ permission_level: { "$lte" => level }}, { permission_level: nil }]) if level

      where({ _id: -1 })
    end

    # @param [String] action
    # @param [Cms::User] user
    def allow_with_route(action, user, opts = {})
      site_id = opts[:site] ? opts[:site].id : criteria.selector["site_id"]

      action = permission_action || action

      permissions = user.cms_roles.where(site_id: site_id).map(&:permissions).flatten.uniq
      permissions = permissions.select { |permit| permit =~ /^#{action}_/ }

      others = permissions.select { |permit| permit =~ /_other_/ }
      privates = permissions.select { |permit| permit =~ /_private_/ }



      user.cms_roles.first.permissions
    end
  end

  private
    def template_variable_handler_group(name, issuer)
      group = self.groups.first
      group ? group.name.split(/\//).pop : ""
    end

    def template_variable_handler_groups(name, issuer)
      self.groups.map { |g| g.name.split(/\//).pop }.join(", ")
    end
end
