class Riken::MS365::Diag::RoomListsController < ApplicationController
  include Gws::BaseFilter

  navi_view 'riken/ms365/main/conf_navi'

  before_action :check_permissions

  private

  def check_permissions
    raise "403" unless Gws::Group.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_crumbs
    @crumbs << [t("riken.ms365.main"), gws_riken_ms365_main_path]
    @crumbs << [t("riken.ms365.room_list"), url_for(action: :index)]
  end
end
