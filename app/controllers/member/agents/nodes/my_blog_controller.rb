class Member::Agents::Nodes::MyBlogController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud

  model Member::BlogPage

  before_action :set_blog

  #prepend_view_path "app/views/member/agents/nodes/mypage/blog"

  helper Cms::ListHelper

  public
    def index
      @items = @model.site(@cur_site).member(@cur_member).
        order_by(released: -1).
        page(params[:page]).per(50)
    end

  private
    def fix_params
      { cur_site: @cur_site, cur_member: @cur_member, blog: @blog }
    end

    def set_item
      super
      @cur_node.name = @item.name
    end

    def set_blog
      @blog = @cur_node.blog(@cur_member)
      redirect_to "#{@cur_node.setting_url}new" unless @blog
    end
end
