class Circle::CategoriesController < ApplicationController
  include Cms::BaseFilter
  include Cms::NodeFilter

  model Circle::Node::Category

  prepend_view_path "app/views/cms/node/nodes"
  navi_view "circle/categories/navi"

  private
    def set_item
      super
      raise "404" if @item.id == @cur_node.id
    end

    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, cur_node: @cur_node }
    end

    def pre_params
      { route: "circle/category" }
    end

  public
    def index
      @items = @model.site(@cur_site).node(@cur_node).
        allow(:read, @cur_user).
        order_by(filename: 1).
        page(params[:page]).per(50)
    end
end
