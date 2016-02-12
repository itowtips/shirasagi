class Member::Agents::Nodes::MyProfileController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::PublicFilter::Crud

  model Cms::Member
  helper Member::MypageHelper

  before_action :set_item

  prepend_view_path "app/views/member/agents/nodes/my_profile"

  public
    def index
    end

  private
    def set_item
      @item = @cur_member
    end
end
