class Member::Agents::Nodes::PippiMypageController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter

  def index
    @item = @cur_member
    @profile_node = Member::Node::PippiProfile.site(@cur_site).first
    @bookmarks = @cur_member.bookmarks.to_a
  end
end
