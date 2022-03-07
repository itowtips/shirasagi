module Gws::Portal::PortletFilter
  extend ActiveSupport::Concern

  included do
    menu_view 'gws/portal/common/portlets/menu'
    before_action :set_preset_portlet
    before_action :set_portlet_addons
  end

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site, setting_id: @portal.try(:id) }
  end

  def pre_params
    { readable_group_ids: @portal.group_ids, group_ids: @portal.group_ids, user_ids: @portal.user_ids }
  end

  def set_preset_portlet
    @preset_portlet ||= begin
      if params[:preset_portlet_id]
        @preset_setting.portlets.find(params[:preset_portlet_id]) rescue nil
      elsif @item
        @item.preset_portlet
      end
    end
  end

  def set_portlet_addons
    @addons ||= begin
      if @preset_portlet
        @model.preset_addons(@preset_portlet)
      elsif @item
        @model.portlet_addons(@item.portlet_model)
      end
    end
  end

  def prevent_modify_required_portlet
    return if @item.nil?
    return if !@item.required_by_preset?
    redirect_to({ action: :show })
  end

  def new_portlet
    @item = @model.new pre_params.merge(fix_params)
    @item.initialize_by_preset(@preset_portlet) if @preset_portlet

    raise "403" unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    render template: 'gws/portal/common/portlets/select_model' unless @item.portlet_model_enabled?

    if params[:group].present?
      @default_readable_setting = proc do
        @item.readable_setting_range = 'select'
        @item.readable_group_ids = @portal.group_ids + [ @cur_group.id ]
      end
    elsif params[:user].present?
      @default_readable_setting = proc do
        @item.readable_setting_range = 'select'
        @item.readable_member_ids = @portal.user_ids + [ @cur_user.id ]
      end
    end
  end

  public

  def index
    @items = @portal.portlets.
      search(params[:s]).
      order_by("grid_data.row" => 1, "grid_data.col" => 1)
  end

  def new
    new_portlet
  end

  def sync
    raise '403' unless @portal.allowed?(:edit, @cur_user, site: @cur_site)
    return render(template: 'gws/portal/common/portlets/sync') unless request.post?

    @portal.synchronize_portal(@preset_setting)
    redirect_to({ action: :index }, { notice: I18n.t('ss.notice.synced') })
  end

  def reset
    raise '403' unless @portal.allowed?(:edit, @cur_user, site: @cur_site)
    return render(template: 'gws/portal/common/portlets/reset') unless request.post?

    @portal.reset_portal(@preset_setting)
    redirect_to({ action: :index }, { notice: I18n.t('ss.notice.initialized') })
  end
end
