class Member::Agents::Nodes::BlogPageController < ApplicationController
  include Cms::NodeFilter::View

  model Member::BlogPage
  helper Cms::ListHelper
  helper Member::BlogPageHelper
  after_action :render_blog_layout

  public
    def index
      @items = @model.site(@cur_site).node(@cur_node).public.
        search(params).
        order_by(released: -1).
        page(params[:page]).per(50)
    end

    def rss
      @pages = @item.pages.public.
        order_by(released: -1).
        limit(@cur_node.limit)

      render_rss @cur_node, @pages
    end

    def render_blog_layout
      return if response.content_type != "text/html"

      node = @cur_node.becomes_with_route
      layout = @cur_node.layout
      layout.html = layout.html.gsub(/\#\{(.+?)\}/) do |m|
        name = $1
        view_context.render_blog_template(name, node: node) || m
      end
      @cur_node.layout = layout
    end
end
