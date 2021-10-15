class Member::Agents::Nodes::PippiMypageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter

  helper Member::BookmarkHelper

  def index
    @item = @cur_member
    @mypage = @cur_node
    @profile_node = Member::Node::PippiProfile.site(@cur_site).first
  end
end
