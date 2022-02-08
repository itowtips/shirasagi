class Gws::Portal::MainController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::Portal::PortalFilter

  before_action :set_portal_setting

  navi_view "gws/portal/main/navi"

  private

  def set_item
    set_portal_setting
    @item = @portal
  end

  def set_preset
  end

  def set_portal_setting
    return if @portal

    if @cur_user.gws_role_permit_any?(@cur_site, :use_gws_portal_user_settings)
      portal = @cur_user.find_portal_setting(cur_user: @cur_user, cur_site: @cur_site)
      if portal.portal_readable?(@cur_user, site: @cur_site)
        @portal_user = @cur_user
        @portal = portal
        @portal.portal_type = :my_portal

        @preset = @portal_user.find_portal_preset(cur_user: @cur_user, cur_site: @cur_site)
        @preset_setting = @preset.portal_setting if @preset
      end
    elsif @cur_user.gws_role_permit_any?(@cur_site, :use_gws_portal_organization_settings)
      portal = @cur_site.find_portal_setting(cur_user: @cur_user, cur_site: @cur_site)
      if portal.portal_readable?(@cur_user, site: @cur_site)
        @portal_group = @cur_site
        @portal = portal
        @portal.portal_type = :root_portal

        @preset = @portal_group.find_portal_preset(cur_user: @cur_user, cur_site: @cur_site)
        @preset_setting = @preset.portal_setting if @preset
      end
    elsif @cur_group.id != @cur_site.id && @cur_user.gws_role_permit_any?(@cur_site, :use_gws_portal_group_settings)
      portal = @cur_group.find_portal_setting(cur_user: @cur_user, cur_site: @cur_site)
      if portal.portal_readable?(@cur_user, site: @cur_site)
        @portal_group = @cur_group
        @portal = portal
        @portal.portal_type = :group_portal

        @preset = @portal_group.find_portal_preset(cur_user: @cur_user, cur_site: @cur_site)
        @preset_setting = @preset.portal_setting if @preset
      end
    end
    return if @portal.blank?
    @model = @portal.class

    if @portal.new_record? && @preset_setting
      @portal.reset_portal(@preset_setting)
    end
  end

  public

  def show
    show_portal
  end
end
