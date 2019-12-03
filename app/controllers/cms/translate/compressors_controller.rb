class Cms::Translate::CompressorsController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model ::Translate::Compressor
  navi_view "cms/translate/main/navi"

  private

  def fix_params
    { user: @cur_user, cur_site: @cur_site }
  end

  public

  def index
    raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)
    set_items
    @items = @items.search(params[:s])
      .page(params[:page]).per(100)
  end
end
