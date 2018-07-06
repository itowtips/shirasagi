class Gws::Presence::CustomGroup::UsersController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::User

  prepend_view_path "app/views/gws/presence/users"

  menu_view "gws/presence/main/menu"
  navi_view "gws/presence/main/navi"

  before_action :deny_with_auth
  before_action :set_editable_users

  private

  def deny_with_auth
    raise "403" unless Gws::Presence::UserPresence.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def set_crumbs
    set_group
    @crumbs << [t("modules.gws/presence"), gws_presence_users_path]
    @crumbs << [@group.name, gws_presence_custom_group_users_path(group: @group.id)]
  end

  def set_group
    @group = Gws::CustomGroup.site(@cur_site).find(params[:group])
    raise "404" unless @group.member_ids.include?(@cur_user.id)

    @groups = [@cur_site.root.to_a, @cur_site.root.descendants.to_a].flatten
    @custom_groups = Gws::CustomGroup.site(@cur_site).in(member_ids: @cur_user.id)
  end

  def set_editable_users
    @editable_users = @cur_user.presence_editable_users
  end

  public

  def index
    @items = @group.members.search(params[:s]).page(params[:page]).per(25)
  end
end
