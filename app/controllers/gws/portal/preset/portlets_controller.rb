class Gws::Portal::Preset::PortletsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::Portal::PortalFilter
  include Gws::Portal::PortletFilter
  include Gws::Portal::PresetPortalFilter

  model Gws::Portal::PresetPortlet

  prepend_view_path 'app/views/gws/portal/common/portlets'
  navi_view 'gws/portal/main/navi'

  before_action :save_portal_setting

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, setting_id: @portal.try(:id) }
  end

  def pre_params
    {}
  end

  def new_portlet
    @item = @model.new pre_params.merge(fix_params)
    @item.portlet_model = params[:portlet_model]
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)

    @item.name = @item.label(:portlet_model)
    render template: 'gws/portal/preset/portlets/select_model' unless @item.portlet_model_enabled?
  end
end
