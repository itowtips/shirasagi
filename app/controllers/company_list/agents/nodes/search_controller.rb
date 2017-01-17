class CompanyList::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  helper JobDb::ListHelper

  before_action :accept_cors_request, only: [:rss]

  private
    def set_items
      @items = JobDb::Company::Profile.site(@cur_site).and_public(@cur_date)
      @items = @items.
        order_by(@cur_node.sort_hash).
        page(params[:page]).
        per(@cur_node.limit)
    end

  public
    def index
      set_items

      render_with_pagination @items
    end

    def show
      @cur_node.layout_id = @cur_node.page_layout_id
    end

    def rss
      @items = pages.
        order_by(released: -1).
        limit(@cur_node.limit)

      render_rss @cur_node, @items
    end
end
