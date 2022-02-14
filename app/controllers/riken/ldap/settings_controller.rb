class Riken::Ldap::SettingsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Group

  navi_view 'riken/ldap/main/conf_navi'

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
    @crumbs << [t("riken.ldap.main"), gws_riken_ldap_main_path]
    @crumbs << [t("riken.ldap.setting"), url_for(action: :show)]
  end

  public

  def import
    Riken::Ldap::ImportJob.bind(site_id: @cur_site.id).perform_later
    redirect_to url_for(action: :show), notice: t("ss.notice.started_import")
  end
end
