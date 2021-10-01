class Cms::Line::DeliverAgesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Line::DeliverAge

  navi_view "cms/line/main/navi"

  private

  def set_crumbs
    @crumbs << [t("cms.line_deliver_category"), cms_line_deliver_ages_path]
  end

  def fix_params
    { cur_site: @cur_site, cur_user: @cur_user }
  end
end
