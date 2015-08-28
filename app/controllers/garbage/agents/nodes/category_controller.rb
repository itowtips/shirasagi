class Garbage::Agents::Nodes::CategoryController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  public
    def index
      @items = Garbage::Node::Page.site(@cur_site).public.
        where(@cur_node.condition_hash).
        order_by(@cur_node.sort_hash).
        page(params[:page]).
        per(@cur_node.limit)

      if controller.mobile_path?
        render :index_mobile
      else
        render :index
      end
    end
end
