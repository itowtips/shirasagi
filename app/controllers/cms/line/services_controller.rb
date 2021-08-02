class Cms::Line::ServicesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Service::Base

  navi_view "cms/line/main/navi"

  private

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user }
  end

  def set_crumbs
    #@crumbs << [t("cms.sns_post"), cms_sns_post_logs_path]
  end

  def set_model
    return super if params[:action] != "create"

    service = params.dig(:item, :service)
    @model = "Cms::Line::Service::#{service.classify}".constantize
  end
end
