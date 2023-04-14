class Cms::ImageResizesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::ImageResize

  navi_view "cms/main/conf_navi"

  private

  def set_crumbs
    @crumbs << [t('cms.image_resize'), action: :index]
  end

  def fix_params
    { cur_site: @cur_site }
  end
end
