class Member::BlogPagesController < ApplicationController
  include Cms::BaseFilter
  include Cms::CrudFilter

  model Member::BlogPage

  before_action :set_blog

  navi_view "member/blogs/navi"

  public
    def index
      raise "403" unless @model.allowed?(:read, @cur_user, site: @cur_site, node: @cur_node)

      @items = @blog.pages.site(@cur_site).
        allow(:read, @cur_user, site: @cur_site).
        order_by(released: -1).
        page(params[:page]).per(50)
    end

  private
    def set_blog
      @blog = Member::Blog.find params[:blog_id]
    end

    def fix_params
      { cur_user: @cur_user, cur_site: @cur_site, blog: @blog }
    end
end
