class Cms::Line::ServicesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Service

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
    @model = self.class.model_class.service_class(params.dig(:item, :service))
  end
end
