class Gws::Portal::Preset::LayoutsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::Portal::PortalFilter
  include Gws::Portal::PresetPortalFilter

  model Gws::Portal::PresetSetting

  navi_view 'gws/portal/main/navi'
  menu_view 'gws/portal/common/layouts/menu'

  before_action :set_portal_setting
  before_action :save_portal_setting

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_item
    set_portal_setting
    @item = @portal
  end

  public

  def show
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    show_layout
  end

  def update
    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    update_layout
  end
end
