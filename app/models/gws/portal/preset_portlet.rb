class Gws::Portal::PresetPortlet
  include SS::Document
  include Gws::Referenceable
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::Addon::Portal::Portlet::PresetSetting
  include Gws::Portal::PortletModel
  include Gws::SitePermission
  include Gws::Addon::History

  set_permission_name "gws_portal_preset", :manage

  belongs_to :setting, class_name: 'Gws::Portal::PresetSetting'

  def managed_label
    h = []
    h << "[#{label(:managed)}]"
    h << label(:required)
    h << (show_default? ? "/#{t(:show_default)}" : "")
    h.join
  end
end
