class Cms::Translate::TextCachesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model ::Translate::TextCache
  navi_view "cms/translate/main/navi"

  def index
    raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)
    set_items
    @items = @items.search(params[:s])
      .page(params[:page]).per(100)
  end
end
