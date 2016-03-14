class Member::Agents::Nodes::MyPhotoController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud

  model Member::Photo
  helper Member::MypageHelper

  before_action :set_photo_node

  prepend_view_path "app/views/member/agents/nodes/my_photo"

  private
    def set_photo_node
      @photo_node = Member::Node::Photo.first
      @categories = Member::Node::PhotoCategory.site(@cur_site).and_public.order_by(order: 1)
      @locations  = Member::Node::PhotoLocation.site(@cur_site).and_public.order_by(order: 1)
      @layout     = @photo_node.page_layout rescue nil
    end

    def fix_params
      { cur_site: @cur_site, cur_member: @cur_member, cur_node: @photo_node, layout: @layout }
    end

  public
    def index
      @items = @model.site(@cur_site).member(@cur_member).
        order_by(released: -1).
        page(params[:page]).per(50)
    end
end
