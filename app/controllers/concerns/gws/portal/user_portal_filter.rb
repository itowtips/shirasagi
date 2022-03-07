module Gws::Portal::UserPortalFilter
  extend ActiveSupport::Concern

  # 必須設定のポートレットは削除できない
  def destroy_all
    @selected_items = @items = @items.to_a.reject { |item| item.required_by_preset? }
    @selected_items.map(&:destroy) if @selected_items.present?
    render_destroy_all true
  end

  private

  def set_preset
    @portal_user = Gws::User.find(params[:user]) if params[:user].present?
    @portal_user ||= @cur_user
    @preset = @portal_user.find_portal_preset(cur_user: @cur_user, cur_site: @cur_site)
    @preset_setting = @preset.portal_setting if @preset
  end

  def set_portal_setting
    return if @portal

    @portal_user = Gws::User.find(params[:user]) if params[:user].present?
    @portal_user ||= @cur_user
    @portal = @portal_user.find_portal_setting(cur_user: @cur_user, cur_site: @cur_site)
    @portal.portal_type = (@portal_user.id == @cur_user.id) ? :my_portal : :user_portal

    raise '403' unless @portal.portal_readable?(@cur_user, site: @cur_site)
  end
end
