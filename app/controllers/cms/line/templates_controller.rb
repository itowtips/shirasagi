class Cms::Line::TemplatesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::Template

  navi_view "cms/line/main/navi"

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_crumbs
    #@crumbs << [t("cms.sns_post"), cms_sns_post_logs_path]
  end
end
