class Gws::ImageResizesController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::ImageResize

  navi_view 'gws/main/conf_navi'

  private

  def set_crumbs
    @crumbs << [t('cms.image_resize'), action: :index]
  end

  def fix_params
    { cur_site: @cur_site }
  end
end
