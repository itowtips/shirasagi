class Member::Agents::Nodes::MyGroupController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud
  helper Member::MypageHelper

  model Member::Group

  prepend_view_path "app/views/member/agents/nodes/my_group"

  def index
    @items = @model.site(@cur_site).and_member(@cur_member).
      order_by(released: -1).
      page(params[:page]).per(20)
  end
end
