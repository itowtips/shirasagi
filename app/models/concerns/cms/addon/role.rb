module Cms::Addon
  module Role
    extend ActiveSupport::Concern
    extend SS::Addon

    included do
      embeds_ids :cms_roles, class_name: "Cms::Role"
      permit_params cms_role_ids: []
    end

    def exclude_addons(addons)
      hide_addons = []

      cms_roles.each do |role|
        hide_addons += role.hide_addons
      end

      return addons if hide_addons.blank?

      addons.select do |addon|
        klass = addon.klass.to_s.underscore.sub("addon/", "")
        !hide_addons.index(klass)
      end
    end
  end
end
