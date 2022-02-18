class Riken::MS365::SettingsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Group

  navi_view 'riken/ms365/main/conf_navi'

  before_action :check_permissions
  before_action :set_addons

  private

  def check_permissions
    raise "403" unless Gws::Group.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_addons
    @addons = []
  end

  def set_item
    @item = @cur_site
  end

  def set_crumbs
    @crumbs << [t("riken.ms365.main"), gws_riken_ms365_main_path]
    @crumbs << [t("riken.ms365.setting"), url_for(action: :show)]
  end
end
