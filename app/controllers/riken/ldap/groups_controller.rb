require 'net/ldap'

class Riken::Ldap::GroupsController < ApplicationController
  include Gws::BaseFilter

  navi_view 'riken/ldap/main/conf_navi'

  before_action :check_permissions

  private

  def check_permissions
    raise "403" unless Gws::Group.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_crumbs
    @crumbs << [t("riken.ldap.main"), gws_riken_ldap_main_path]
    @crumbs << [t("riken.ldap.group"), url_for(action: :index)]
  end

  def set_search_params
    @s ||= begin
      s = OpenStruct.new(params[:s])
      s.base_dn ||= @cur_site.riken_ldap_group_dn.presence || Riken::Ldap::GROUP_BASE_DN
      s.filter ||= @cur_site.riken_ldap_group_filter.presence || Riken::Ldap::GROUP_FILTER
      s
    end
  end

  public

  def index
    set_search_params
    return if @s.filter.blank?

    connection = @cur_site.riken_ldap_connection!
    filter = Net::LDAP::Filter.construct(@s.filter)
    @result = connection.search(filter: filter, base: @s.base_dn)
  rescue => e
    @error = e
  end
end
