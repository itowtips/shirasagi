class Member::Agents::Nodes::PippiMypageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter
  include Pippi::MypageFilter

  helper Member::BookmarkHelper

  def index
    set_pippi_mypage_contents
  end
end
