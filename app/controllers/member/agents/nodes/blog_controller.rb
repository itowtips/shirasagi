class Member::Agents::Nodes::BlogController < ApplicationController
  include Cms::NodeFilter::View

  before_action :set_item, only: [:show, :show_page, :rss]
  after_action :render_blog_layout, except: :index

  model Member::Blog

  helper Cms::ListHelper

  public
    def index
      @items = @model.site(@cur_site).public.
        order_by(released: -1).
        page(params[:page]).per(50)
    end

    def show
      @pages = @item.pages.public.search(params).
        order_by(released: -1).
        page(params[:page]).per(3)
      @cur_node.name = @item.name
    end

    def show_page
      @page = @item.pages.public.find params[:page_id]
      @cur_node.name = @page.name
    end

    def rss
      @pages = @item.pages.public.
        order_by(released: -1).
        limit(@cur_node.limit)

      render_rss @cur_node, @pages
    end

  private
    def set_item
      @item = @model.where(id: params[:id]).public.first
      raise "404" unless @item
    end

    def render_blog_layout
      return if response.content_type != "text/html"
      layout = @item.layout
      layout.html = layout.html.gsub(/\#\{(.+?)\}/) do |m|
        name = $1
        render_to_string(name, layout: false) rescue m
      end
      @cur_node.layout = layout
    end
end
