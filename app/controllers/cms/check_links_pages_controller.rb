class Cms::CheckLinksPagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Cms::Page
  menu_view  "cms/check_links_contents/menu"
  navi_view  "cms/check_links_contents/navi"
  append_view_path "app/views/cms/check_links_contents"

  def set_items
    @items = @model.site(@cur_site).has_check_links_errors.search(params[:s]).order_by(depth: 1, filename: 1)
    @items = @items.select { |item| item.becomes_with_route.allowed?(:read, @cur_user, site: @cur_site) }
    @items = Kaminari.paginate_array(@items).page(params[:page]).per(50)
  end

  def index
    set_items
  end

  def download
    set_items
  end
end
