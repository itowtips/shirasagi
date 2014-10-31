class Circle::SearchesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Circle::Node::Search

  prepend_view_path "app/views/cms/node/nodes"
  navi_view "circle/main/navi"
  menu_view "circle/page/menu"

  private
    def set_item
      super
      raise "404" if @item.id == @cur_node.id
    end

    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "circle/search" }
    end

  public
    def index
      redirect_to circle_pages_path
      return
    end
end
