class Member::Agents::Nodes::PhotoSpotController < ApplicationController
  include Cms::NodeFilter::View

  model Member::PhotoSpot

  helper Cms::ListHelper

  public
    def index
      @items = @model.site(@cur_site).public.
        order_by(released: -1).
        page(params[:page]).per(50)
    end

    def rss
      @pages = @item.pages.public.
        order_by(released: -1).
        limit(@cur_node.limit)

      render_rss @cur_node, @pages
    end
end
