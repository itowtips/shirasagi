class Riken::Payment::SettingsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Riken::Payment::ImporterSetting

  navi_view 'riken/payment/main/conf_navi'

  before_action :check_permissions

  private

  def check_permissions
    raise "403" unless Riken::Payment::ImporterSetting.allowed?(:edit, @cur_user, site: @cur_site)
  end

  def fix_params
    { cur_site: @cur_site }
  end

  def set_item
    @item = @model.find_or_initialize_by(site_id: @cur_site.id)
    @item.attributes = fix_params
    #@item.in_updated = Time.zone.now.advance(days: -1) if @item.new_record?
  end

  def set_crumbs
    @crumbs << [t("riken.payment.main"), gws_riken_payment_main_path]
    @crumbs << [t("riken.payment.setting"), url_for(action: :show)]
  end

  public

  def update
    @item.attributes = get_params
    @item.in_updated = params[:_updated] if @item.respond_to?(:in_updated) && @item.persisted?
    return render_update(false) unless @item.allowed?(:edit, @cur_user, site: @cur_site)
    render_update @item.update
  end
end
