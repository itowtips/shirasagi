class Opendata::Agents::Nodes::Dataset::SearchDatasetController < ApplicationController
  include Cms::NodeFilter::View
  helper Opendata::UrlHelper

  private
    def pages
      @model = Opendata::Dataset

      focus = params[:s] || {}
      focus = focus.merge(site: @cur_site)

      sort = Opendata::Dataset.sort_hash params[:sort]

      @model.site(@cur_site).public.
        search(focus).
        order_by(sort)
    end

    def st_categories
      @cur_node.parent_dataset_node.st_categories.presence || @cur_node.parent_dataset_node.default_st_categories
    end

  public
    def index
      @cur_categories = st_categories
      @items = pages.page(params[:page]).per(20)
    end

    def rss
      @items = pages.limit(100)
      render_rss @cur_node, @items
    end
end
