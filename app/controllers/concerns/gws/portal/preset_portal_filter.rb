module Gws::Portal::PresetPortalFilter
  extend ActiveSupport::Concern

  included do
    before_action :set_portal_setting
  end

  def show_layout
    @items = @portal.default_portlets
    render template: 'gws/portal/common/layouts/show'
  end

  public

  def index
    @items = @portal.portlets.
      search(params[:s]).
      reorder(order: 1)
  end

  private

  def set_preset
    @preset ||= Gws::Portal::Preset.site(@cur_site).find(params[:preset])
  end

  def set_preset_portlet
  end

  def set_portlet_addons
    portlet_model = params[:portlet_model].presence
    portlet_model = @item.portlet_model if @item
    @addons = @model.portlet_addons(portlet_model) if portlet_model
  end

  def set_portal_setting
    return if @portal

    set_preset
    @portal = @preset.portal_setting
    @portal.cur_user = @cur_user
    @portal.portal_user = @cur_user
    #@portal.portal_type = :preset_portal
    raise '403' unless @portal.portal_readable?(@cur_user, site: @cur_site)
  end

  def set_crumbs
    @crumbs << [t("gws/portal.preset"), gws_portal_presets_path]
  end
end
