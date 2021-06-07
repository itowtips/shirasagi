class Cms::Line::Poster::SegmentDeliveriesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Poster::Delivery

  navi_view "cms/line/main/navi"

  public

  def deliver
    set_item
    @items = @item.target_members.page(params[:page]).per(50)
    return if request.get?

    @item.deliver
    render_create true
  end

  private

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user }
  end

  def set_crumbs
    #@crumbs << [t("cms.sns_post"), cms_sns_post_logs_path]
  end
end
