class Cms::Line::FacilitySearch::CategoriesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::FacilitySearch::Category

  navi_view "cms/line/main/navi"

  before_action :set_service

  private

  def set_service
    @service = Cms::Line::Service::Base.find(params[:service_id])
  end

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user, service: @service }
  end

  def set_crumbs
    #@crumbs << [t("cms.sns_post"), cms_sns_post_logs_path]
  end
end
