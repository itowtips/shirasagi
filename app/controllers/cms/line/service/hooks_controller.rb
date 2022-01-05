class Cms::Line::Service::HooksController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Service::Hook::Base

  navi_view "cms/line/main/navi"

  before_action :set_service_group

  private

  def set_crumbs
    @crumbs << [t("cms.line_service"), cms_line_service_groups_path]
    @crumbs << [t("cms.line_service_hook"), cms_line_service_group_hooks_path]
  end

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user, group: @service_group }
  end

  def set_service_group
    @service_group = Cms::Line::Service::Group.site(@cur_site).find(params[:group_id])
  end

  def set_model
    return super if params[:action] != "create"

    service = params.dig(:item, :service)
    @model = "Cms::Line::Service::Hook::#{service.classify}".constantize
  end

  def set_items
    @items = @service_group.hooks
  end
end
